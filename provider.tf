# backend stuff for storing lock file.
terraform {
  backend "azurerm" {
    resource_group_name  = "dvo_terraform"
    storage_account_name = "terraformlock"
    container_name       = "jenkins"
    key                  = "arm.jenkins.lock"
  }
}

provider "azurerm" {
  subscription_id = "9fbf7025-df40-4908-b7fb-a3a2144cee91"
}
