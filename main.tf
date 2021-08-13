provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  # version = "1.27.0"

  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

locals {
  //general
  resource_group_name = (var.resource_group_name == "none") ? azurerm_resource_group.new-rs[0].name : var.resource_group_name

  active_directory_netbios_name = element(split(".", var.master_domain), 0)
  client_vm_size                = "Standard_B4ms"
  dc_vm_size                    = "Standard_B8ms"

  // networking
  virtual_net_addr_space = "10.10.0.0/16"
  subnet_address_prefix  = [for index in range(var.num_of_labs ) : cidrsubnet(local.virtual_net_addr_space, 8, index)] //["10.10.1.0/24","10.10.2.0/24","10.10.3.0/24"]

  //domain settings section
  domain_subnet_prefix = "10.10.98.0/24" //dont change
  dc_private_ip        = "10.10.98.10"   // dont change DC Svr private IP = 10.10.98.10

}

data "azurerm_resource_group" "lab" {
  name = local.resource_group_name
  // location = var.location
  count = (var.resource_group_name == "none") ? 0 : 1
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "azurerm_resource_group" "new-rs" {
  name     = join("-", [ var.prefix,"HOL",random_string.suffix.result] )
  location = var.location

  tags = {
    environment = "Demo"
  }

  count = (var.resource_group_name == "none") ? 1 : 0
}

## get localhost public IP address
# data "http" "myip" {
#   url = "http://ipinfo.io/ip"
# }

module "lab-DC" {
  source                        = "./modules/active-directory"
  resource_group_name           = local.resource_group_name
  location                      = var.location
  prefix                        = var.prefix
  local_time  = var.local_time
  subnet_id                     = azurerm_subnet.dc-subnet.id
  dc_private_ip                 = local.dc_private_ip
  active_directory_domain       = var.master_domain
  active_directory_netbios_name = local.active_directory_netbios_name
  domain_admin_username         = var.domain_admin_username
  domain_admin_password         = var.domain_admin_password
  domain_user_password          = var.domain_user_password
  domain_usernames              = var.users
  win_server_version = var.win_server_version
  vm_size = local.dc_vm_size

}

module "lab-jump-host" {
  source                        = "./modules/windows-client1"
  resource_group_name           = local.resource_group_name
  location                      = var.location
  prefix                        = "${var.prefix}-TECHJump${count.index}"
  subnet_id                     = azurerm_subnet.victim-subnets[count.index].id
  dc_private_ip                 = local.dc_private_ip
  local_time  = var.local_time
  active_directory_domain       = var.master_domain
  active_directory_username     = var.domain_admin_username
  active_directory_password     = var.domain_admin_password
  active_directory_netbios_name = local.active_directory_netbios_name
  domain_user_password          = var.domain_user_password
  admin_username                = var.users[count.index].email_account
  admin_password                = var.domain_user_password
  apex_agent                    = var.apex_agent
  networksec_group              = azurerm_network_security_group.lab-secgroup[count.index].id
  vm_size                       = local.client_vm_size
  win_client_version = var.win_client_version
  jump_host                     = true

  count = var.num_of_labs
}

module "lab-victim-1" {
  source                        = "./modules/windows-client1"
  resource_group_name           = local.resource_group_name
  location                      = var.location
  prefix                        = "${var.prefix}-TECH01${count.index}"
  subnet_id                     = azurerm_subnet.victim-subnets[count.index].id
  dc_private_ip                 = local.dc_private_ip
  local_time  = var.local_time
  active_directory_domain       = var.master_domain
  active_directory_username     = var.domain_admin_username
  active_directory_password     = var.domain_admin_password
  active_directory_netbios_name = local.active_directory_netbios_name
  domain_user_password          = var.domain_user_password
  admin_username                = var.users[count.index].internal_domain_username
  admin_password                = var.domain_user_password
  apex_agent                    = var.apex_agent
  networksec_group              = azurerm_network_security_group.lab-secgroup[count.index].id
  vm_size                       = local.client_vm_size
  win_client_version = var.win_client_version
  jump_host                     = false

  count = var.num_of_labs
}

resource "azurerm_network_security_group" "lab-secgroup" {
  name                = "${var.prefix}-rdp-${count.index}"
  resource_group_name = local.resource_group_name
  location            = var.location
  security_rule {
    name                       = "${var.prefix}-rdp-rule-mgmt"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 200
    source_address_prefix      = var.users[count.index].management_ip
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "3389"
    protocol                   = "TCP"
  }
  security_rule {
    name                       = "${var.prefix}-internal-in"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 300
    source_address_prefix      = local.virtual_net_addr_space
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    protocol                   = "*"
  }
  security_rule {
    name                       = "${var.prefix}-internal-out"
    direction                  = "Outbound"
    access                     = "Allow"
    priority                   = 400
    source_address_prefix      = local.virtual_net_addr_space
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    protocol                   = "*"
  }

  count = var.num_of_labs
}
