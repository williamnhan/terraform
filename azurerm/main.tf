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

locals {
  web_server_name = var.enviroment == "production" ? "${var.web_server_name}-prd" : "${var.web_server_name}-dev"
  build_environment = var.enviroment == "production" ? "production" : "development"
}

resource "azurerm_resource_group" "web_server_rg" {
  name     = var.web_server_rg
  location = var.web_server_location

  tags = {
    environment = local.build_environment
    build_environment = var.terraform_script_version
  }
}

resource "azurerm_virtual_network" "web_server_vnet" {
  name = "${var.resource_prefix}-vnet"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  address_space = [var.web_server_address_space]
}

resource "azurerm_subnet" "web_server_subnet" {
  for_each = var.web_server_subnet
    name = each.key
    resource_group_name = azurerm_resource_group.web_server_rg.name
    virtual_network_name = azurerm_virtual_network.web_server_vnet.name
    address_prefixes = [each.value]
}

resource "azurerm_network_interface" "web_server_nic" {
  name = "${var.web_server_name}-${format("%02d", count.index)}-nic"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  # count = var.web_server_count
  count = 0

  ip_configuration {
    name = "${var.web_server_name}-ip"
    subnet_id = azurerm_subnet.web_server_subnet["web-server"].id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = count.index == 0 ? azurerm_public_ip.web_server_public_ip.id : null
  }
}

resource "azurerm_public_ip" "web_server_public_ip" {
  name = "${var.resource_prefix}-public-ip"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  allocation_method = var.enviroment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "web_server_nsg" {
  name = "${var.resource_prefix}-nsg"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
}

resource "azurerm_network_security_rule" "web_server_nsg_rule_rdp" {
  name = "RDP Inbound"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3389"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.web_server_rg.name
  network_security_group_name = azurerm_network_security_group.web_server_nsg.name
  count = var.enviroment == "production" ? 0 : 1
}
resource "azurerm_network_security_rule" "web_server_nsg_rule_http" {
  name = "HTTP Inbound"
  priority = 110
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.web_server_rg.name
  network_security_group_name = azurerm_network_security_group.web_server_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "web_server_nsg_association" {
  network_security_group_id = azurerm_network_security_group.web_server_nsg.id
  subnet_id = azurerm_subnet.web_server_subnet["web-server"].id
}

# // Get Image list and size from Azure
# az vm image list -o table
# az vm image list-offers -l westus2 --output table
# az vm image list-offers -l westus2 -p MicrosoftWindowsServer -o table
# az vm list-sizes -l westus2 -o table
# az vm image list-offers -l westus2 -p MicrosoftWindowsServer -o table

resource "azurerm_windows_virtual_machine" "web_server" {
  name = "${var.web_server_name}-${format("%02d", count.index)}"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  network_interface_ids = [azurerm_network_interface.web_server_nic[count.index].id]
  # availability_set_id = azurerm_availability_set.web_server_availability_set.id
  # count = var.web_server_count
  count = 0

  size = "Standard_B1s"
  admin_username = "webserver"
  admin_password = "Passw0rd321"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServerSemiAnnual"
    sku = "Datacenter-Core-1709-smalldisk"
    version = "latest"
  }
}

# resource "azurerm_availability_set" "web_server_availability_set" {
#   name = "${var.resource_prefix}-availability-set"
#   location = var.web_server_location
#   resource_group_name = azurerm_resource_group.web_server_rg.name
#   managed = true
#   platform_fault_domain_count = 2
# }

resource "azurerm_virtual_machine_scale_set" "web_server" {
  name = "${local.web_server_name}-scale-set"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name
  upgrade_policy_mode = "manual"

  sku {
    name = "Standard_B1s"
    tier = "Standard"
    capacity = var.web_server_count
  }
  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServerSemiAnnual"
    sku = "Datacenter-Core-1709-smalldisk"
    version = "latest"
  }
  storage_profile_os_disk {
    name = ""
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name_prefix = local.web_server_name
    admin_username = "webserver"
    admin_password = "Passw0rd321"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
  network_profile {
    name = "web_server_network_profile"
    primary = true
    ip_configuration {
      name = local.web_server_name
      primary = true
      subnet_id = azurerm_subnet.web_server_subnet["web-server"].id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_server_lb_backend_pool.id]
    }
  }
  extension {
    name = "${local.web_server_name}-extension"
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"

    settings = jsonencode({
      "fileUris" : ["https://raw.githubusercontent.com/williamnhan/terraform/master/azurerm/azureInstallWebServer.ps1"],
      "commandToExecute" : "start powershell -ExecutionPolicy Unrestricted -File azureInstallWebServer.ps1"
    })
  }
}

resource "azurerm_lb" "web_server_lb" {
  name = "${var.resource_prefix}-lb"
  location = var.web_server_location
  resource_group_name = azurerm_resource_group.web_server_rg.name

  frontend_ip_configuration {
    name = "${var.resource_prefix}-lb-frontend-ip"
    public_ip_address_id = azurerm_public_ip.web_server_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_server_lb_backend_pool" {
  name = "${var.resource_prefix}-lb-backend-pool"
  loadbalancer_id = azurerm_lb.web_server_lb.id
}

resource "azurerm_lb_probe" "web_server_lb_http_probe" {
  name = "${var.resource_prefix}-lb-http-probe"
  resource_group_name = azurerm_resource_group.web_server_rg.name
  loadbalancer_id = azurerm_lb.web_server_lb.id
  protocol = "tcp"
  port = "80"
}
resource "azurerm_lb_rule" "web_server_lb_http_rule" {
  name = "${var.resource_prefix}-lb-http-rule"
  resource_group_name = azurerm_resource_group.web_server_rg.name
  loadbalancer_id = azurerm_lb.web_server_lb.id
  protocol = "tcp"
  frontend_port = "80"
  backend_port = "80"
  frontend_ip_configuration_name = "${var.resource_prefix}-lb-frontend-ip"
  probe_id = azurerm_lb_probe.web_server_lb_http_probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_server_lb_backend_pool.id
}