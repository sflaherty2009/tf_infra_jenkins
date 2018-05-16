variable "resource_group_name" {
  default = "azl-mdn-jnks-02"
}

variable "location" {
  description = "The default Azure region for the resource provisioning"
  default     = "East US 2"
}

variable "lin_image_publisher" {
  description = "Publisher name of the linux machine image"
  default     = "OpenLogic"
}

variable "lin_image_offer" {
  description = "Offer name of the linux machine image"
  default     = "CentOS"
}

variable "lin_image_sku" {
  description = "SKU of the linux machine image"
  default     = "7.4"
}

variable "lin_image_version" {
  description = "Image version desired for linux machines"
  default     = "7.4.20180118"
}

variable "admin_password" {
  description = "Enter admin password to SSH into VM"
  default     = "R0llW1th!t"
}

variable "admin_user" {
  description = "Enter admin username to SSH into Linux VM"
  default     = "local_admin"
}

variable "computer_name" {
  default = "azl-mdn-jnks-02"
}

variable "vm_size" {
  default = "Standard_D1"
}

variable "count_jenkins_vms" {
  description = "Number of desired jenkins vms"
  default     = 1
}

# this can be found using resource explorer in hte azure portal.  This one is Int-Mgmt
variable "subnet_id" {
  description = "Full path of the subnet desired for the node"
  default     = "/subscriptions/9fbf7025-df40-4908-b7fb-a3a2144cee91/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-02/subnets/AZ-SN-dvo"
}

variable "chef_server_url" {
  description = "Enter full chef url using private ip"
  default     = "https://10.16.192.4/organizations/trek"
}

variable "chef_environment" {
  description = "Enter desired environment to be setup on chef server"
  default     = "development"
}

variable "chef_user_name" {
  description = "Enter username to be utilized with validation key"
  default     = "trek-validator"
}

variable "chef_runlist" {
  default = "cb_dvo_resolveDNS, cb_dvo_chefClient, cb_dvo_selinux, cb_dvo_addStorage, cb_dvo_adJoin, cb_dvo_sshd, cb_dvo_authorization, cb_dvo_prtg, cb_dvo_localAccounts, cb_dvo_jenkins"
}

variable "chef_client_version" {
  description = "Version of Chef-Client to utilized during provision time"
  default     = "13.8.5"
}
