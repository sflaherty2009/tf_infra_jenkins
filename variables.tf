variable "subscription_id" {
  default = {
    "default" = "9db13c96-62ad-4945-9579-74aeed296e48"
    "mdn"     = "9db13c96-62ad-4945-9579-74aeed296e48"
    "ss"      = "9db13c96-62ad-4945-9579-74aeed296e48"
    "prd"     = "9fbf7025-df40-4908-b7fb-a3a2144cee91"
  }
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

variable "vm_size" {
  default = {
    "default" = "Standard_D2_v2"
    "mdn"     = "Standard_D2_v2"
    "ss"      = "Standard_D2_v2"
    "prd"     = "Standard_D2_v2"
  }
}

variable "count_jenkins_vms" {
  description = "Number of desired jenkins vms"

  default = {
    "default" = 1
    "mdn"     = 1
    "ss"      = 1
    "prd"     = 1
  }
}

variable "subnet_id" {
  description = "Full path of the subnet desired for the node"

  default = {
    "default" = "/subscriptions/9db13c96-62ad-4945-9579-74aeed296e48/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-01/subnets/AZ-SN-dvo"
    "mdn"     = "/subscriptions/9db13c96-62ad-4945-9579-74aeed296e48/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-01/subnets/AZ-SN-dvo"
    "ss"      = "/subscriptions/9db13c96-62ad-4945-9579-74aeed296e48/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-01/subnets/AZ-SN-dvo"
    "prd"     = "/subscriptions/9fbf7025-df40-4908-b7fb-a3a2144cee91/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-02/subnets/AZ-SN-dvo"
  }
}

variable "chef_server_url" {
  description = "Enter full chef url using private ip"
  default     = "https://10.16.192.4/organizations/trek"
}

variable "chef_environment" {
  description = "Enter desired environment to be setup on chef server"

  default = {
    "default" = "development"
    "mdn"     = "development"
    "ss"      = "testing"
    "prd"     = "production"
  }
}

variable "chef_user_name" {
  description = "Enter username to be utilized with validation key"
  default     = "trek-validator"
}

variable "chef_runlist" {
  default = "cb_dvo_resolveDNS, cb_dvo_chefClient, cb_dvo_selinux, cb_dvo_addstorage, cb_dvo_adJoin, cb_dvo_sshd, cb_dvo_authorization, cb_dvo_prtg, cb_dvo_docker, cb_dvo_localAccounts, cb_dvo_jenkins"
}

variable "chef_client_version" {
  description = "Version of Chef-Client to utilized during provision time"
  default     = "13.8.5"
}

locals {
  admin_credentials = "${split("\n",file("${path.module}/secrets/admin_credentials"))}"
  admin_user        = "${local.admin_credentials[0]}"
  admin_password    = "${local.admin_credentials[1]}"
}
