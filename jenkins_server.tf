# backend stuff for storing lock file.
terraform {
  backend "azurerm" {
    resource_group_name  = "dvo_terraform"
    storage_account_name = "terraformlock"
    container_name       = "jenkins"
    key                  = "arm.jenkins.lock"
    access_key           = "tPLgDxuAjzeFu32JO5DwD6eh53+TrKyQ+fgohBmvFlH12WzU9PaDM64oNAtQYxk5Pd/m78J0yhPgOC5cja+tVA=="
  }
}

# Create resource group that will be used with Jenkins deploy
resource "azurerm_resource_group" "jenkins" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

# Create public IPs
resource "azurerm_public_ip" "jenkins" {
  name                         = "${var.computer_name}-pubip"
  location                     = "${azurerm_resource_group.jenkins.location}"
  resource_group_name          = "${azurerm_resource_group.jenkins.name}"
  public_ip_address_allocation = "static"
}

# Create virtual NIC that will be used with our Jenkins instance.
resource "azurerm_network_interface" "jenkins" {
  name                = "${azurerm_resource_group.jenkins.name}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"

  ip_configuration {
    name                          = "${var.computer_name}-ipconf"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.jenkins.*.id, count.index)}"
  }
}

# STORAGE =======================================
# resource "azurerm_storage_account" "test" {
#   name                     = "${var.storageaccount}"
#   resource_group_name      = "${azurerm_resource_group.jenkins.name}"
#   location                 = "${var.location}"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "test" {
#   name                  = "vhds"
#   resource_group_name   = "${azurerm_resource_group.jenkins.name}"
#   storage_account_name  = "${azurerm_storage_account.test.name}"
#   container_access_type = "private"
# }

# VIRTUAL MACHINE ================================
resource "azurerm_virtual_machine" "jenkins" {
  name                  = "${var.computer_name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.jenkins.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins.id}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name              = "${var.computer_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # storage_os_disk {
  #   name          = "${var.computer_name}-osdisk"
  #   vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/${var.computer_name}-osdisk.vhd"
  #   caching       = "ReadWrite"
  #   create_option = "FromImage"
  # }

  os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${file("ssh/id_rsa.pub")}"
    }
  }
  connection {
    type = "ssh"
    host = "${element(azurerm_public_ip.jenkins.*.ip_address, count.index)}"
    user = "${var.admin_user}"

    # password = "${var.admin_password}"
    private_key = "${file("ssh/id_rsa")}"
    agent       = false
  }
  provisioner "local-exec" {
    command = "echo 'sleeping'"
  }
  provisioner "local-exec" {
    command = "sleep 220"
  }
  provisioner "local-exec" {
    command = "echo 'done sleeping'"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "knife node delete ${var.computer_name} -y; knife client delete ${var.computer_name} -y"
  }
}

resource "azurerm_virtual_machine_extension" "jenkins" {
  name                       = "ChefClient"
  location                   = "${var.location}"
  resource_group_name        = "${azurerm_resource_group.jenkins.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.jenkins.name}"
  publisher                  = "Chef.Bootstrap.WindowsAzure"
  type                       = "LinuxChefClient"
  type_handler_version       = "1210.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {    
    "client_rb": "ssl_verify_mode :verify_none",
    "bootstrap_options": {
      "chef_node_name": "${var.computer_name}",
      "chef_server_url": "${var.chef_server_url}",
      "environment": "${var.chef_environment}",
      "validation_client_name": "${var.chef_user_name}"
    },
    "runlist": "${var.chef_runlist}"
  }
  SETTINGS

  protected_settings = <<SETTINGS
  {
    "validation_key": "${file("ssh/validation.pem")}"
  }
  SETTINGS
}
