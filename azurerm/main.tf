terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "web_server_rg" {
  name     = var.web_server_rg
  location = var.web_server_location
}

resource "azurerm_virtual_network" "web_server_vnet" {
  name = "${var.resource_prefix}-vnet"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  address_space = [var.web_server_address_space]
}

resource "azurerm_subnet" "web_server_subnet" {
  name = "${var.resource_prefix}-subnet"
  resource_group_name = azurerm_resource_group.web_server_rg.name
  virtual_network_name = azurerm_virtual_network.web_server_vnet.name
  address_prefixes = [var.web_server_address_prefix]
}