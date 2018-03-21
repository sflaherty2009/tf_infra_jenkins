data "terraform_remote_state" "jenkins" {
  backend = "azurerm"

  config {
    resource_group_name  = "dvo_terraform"
    storage_account_name = "terraformlock"
    container_name       = "jenkins01"
    key                  = "arm.jenkins.lock"
    access_key           = "tPLgDxuAjzeFu32JO5DwD6eh53+TrKyQ+fgohBmvFlH12WzU9PaDM64oNAtQYxk5Pd/m78J0yhPgOC5cja+tVA=="
  }
}
