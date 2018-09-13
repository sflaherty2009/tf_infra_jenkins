# Create resource group that will be used with Jenkins deploy
resource "azurerm_resource_group" "jenkins" {
  name     = "AZ-RG-${upper(terraform.workspace)}-JNKS"
  location = "${var.location}"
}

# Create public IPs
resource "azurerm_public_ip" "jenkins" {
  name                         = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}-pubip"
  location                     = "${azurerm_resource_group.jenkins.location}"
  resource_group_name          = "${azurerm_resource_group.jenkins.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}"
  count                        = "${lookup(var.count_jenkins_vms,terraform.workspace)}"
}

# Create virtual NIC that will be used with our Jenkins instance.
resource "azurerm_network_interface" "jenkins" {
  name                = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}-nic"
  location            = "${azurerm_resource_group.jenkins.location}"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"
  count               = "${lookup(var.count_jenkins_vms,terraform.workspace)}"

  ip_configuration {
    name                          = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}-ipconf"
    subnet_id                     = "${lookup(var.subnet_id,terraform.workspace)}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.jenkins.*.id, count.index)}"
  }
}

resource "azurerm_storage_account" "jenkins" {
  name                     = "azl${terraform.workspace}jnks${format("%02d", count.index+1)}s"
  resource_group_name      = "${azurerm_resource_group.jenkins.name}"
  location                 = "${azurerm_resource_group.jenkins.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  count                    = "${lookup(var.count_jenkins_vms,terraform.workspace)}"
}

resource "azurerm_storage_container" "jenkins" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.jenkins.name}"
  storage_account_name  = "${element(azurerm_storage_account.jenkins.*.name, count.index)}"
  container_access_type = "private"
  count                 = "${lookup(var.count_jenkins_vms,terraform.workspace)}"
}

resource "azurerm_virtual_machine" "jenkins" {
  name                  = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}"
  location              = "${azurerm_resource_group.jenkins.location}"
  resource_group_name   = "${azurerm_resource_group.jenkins.name}"
  network_interface_ids = ["${element(azurerm_network_interface.jenkins.*.id, count.index)}"]
  vm_size               = "${lookup(var.vm_size,terraform.workspace)}"
  count                 = "${lookup(var.count_jenkins_vms,terraform.workspace)}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  provisioner "local-exec" {
    when    = "destroy"
    command = "knife node delete azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}-${azurerm_resource_group.jenkins.name} -y; knife client delete azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}-${azurerm_resource_group.jenkins.name} -y"
  }

  storage_image_reference {
    publisher = "${var.lin_image_publisher}"
    offer     = "${var.lin_image_offer}"
    sku       = "${var.lin_image_sku}"
    version   = "${var.lin_image_version}"
  }

  storage_os_disk {
    name          = "osdisk"
    vhd_uri       = "${element(azurerm_storage_account.jenkins.*.primary_blob_endpoint, count.index)}${element(azurerm_storage_container.jenkins.*.name, count.index)}/osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk-0"
    vhd_uri       = "${element(azurerm_storage_account.jenkins.*.primary_blob_endpoint, count.index)}${element(azurerm_storage_container.jenkins.*.name, count.index)}/datadisk-0.vhd"
    disk_size_gb  = "979"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "azl-${terraform.workspace}-jnks-${format("%02d", count.index+1)}"
    admin_username = "${local.admin_user}"
    admin_password = "${local.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "jenkins" {
  name                       = "ChefClient"
  location                   = "${azurerm_resource_group.jenkins.location}"
  resource_group_name        = "${azurerm_resource_group.jenkins.name}"
  virtual_machine_name       = "${element(azurerm_virtual_machine.jenkins.*.name, count.index)}"
  publisher                  = "Chef.Bootstrap.WindowsAzure"
  type                       = "LinuxChefClient"
  type_handler_version       = "1210.12"
  auto_upgrade_minor_version = true
  count                      = "${lookup(var.count_jenkins_vms,terraform.workspace)}"

  settings = <<SETTINGS
  {
    "client_rb": "ssl_verify_mode :verify_none",
    "bootstrap_version": "${var.chef_client_version}",
    "bootstrap_options": {
      "chef_node_name": "${element(azurerm_virtual_machine.jenkins.*.name, count.index)}-${azurerm_resource_group.jenkins.name}",
      "chef_server_url": "${var.chef_server_url}",
      "environment": "${lookup(var.chef_environment,terraform.workspace)}",
      "validation_client_name": "${var.chef_user_name}"
    },
    "runlist": "${var.chef_runlist}"
  }
  SETTINGS

  protected_settings = <<SETTINGS
  {
    "validation_key": "${file("${path.module}/secrets/validation.pem")}",
    "secret": "${file("${path.module}/secrets/jenkins_secret")}"
  }
  SETTINGS
}
