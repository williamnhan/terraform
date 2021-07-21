terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
    random = {
      version = "2.2"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "random" {
}

module "location_us2w" {
  source = "./location"

  web_server_location       = "westus2"
  web_server_rg             = "${var.web_server_rg}-us2w"
  resource_prefix           = "${var.resource_prefix}-us2w"
  web_server_address_space  = "1.0.0.0/22"
  web_server_name           = var.web_server_name
  environment               = var.environment
  web_server_count          = var.web_server_count
  web_server_subnet         = {
    web-server              = "1.0.1.0/24"
    AzureBastionSubnet      = "1.0.2.0/24"
  }
  terraform_script_version  = var.terraform_script_version
  admin_password            = data.azurerm_key_vault_secret.admin_password.value
}

# module "location_us2e" {
#   source = "./location"

#   web_server_location       = "eastus2"
#   web_server_rg             = "${var.web_server_rg}-us2e"
#   resource_prefix           = "${var.resource_prefix}-us2e"
#   web_server_address_space  = "2.0.0.0/22"
#   web_server_name           = var.web_server_name
#   environment               = var.environment
#   web_server_count          = var.web_server_count
#   web_server_subnet         = {
#     web-server              = "2.0.1.0/24"
#     AzureBastionSubnet      = "2.0.2.0/24"
#   }
#   terraform_script_version  = var.terraform_script_version
#   admin_password            = data.azurerm_key_vault_secret.admin_password.value
# }