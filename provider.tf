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

provider "azurerm" {
  subscription_id = "9fbf7025-df40-4908-b7fb-a3a2144cee91"
  client_id       = "b02a02fc-10a9-496c-b7fc-16fa72c5d3e4"
  client_secret   = "/TwccqeAqW4VUXmZwP3lwiLjokslMW18434HX/BFpzU="
  tenant_id       = "9dcd6c72-99eb-423d-b4d9-794d81eef415"
}
