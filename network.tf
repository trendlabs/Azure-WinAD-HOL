resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = [local.virtual_net_addr_space]
  location            = var.location
  resource_group_name = local.resource_group_name
  dns_servers         = [local.dc_private_ip, "1.1.1.1"]
}

resource "azurerm_subnet" "victim-subnets" {
  count                = var.num_of_labs
  name                 = "${var.prefix}-VictimNet-${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnet_address_prefix[count.index]] //"10.10.98.0/24"
}

resource "azurerm_subnet" "dc-subnet" {

  name                 = "${var.prefix}-DCnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.domain_subnet_prefix] //"10.10.98.0/24"
}

resource "azurerm_route_table" "dc-2-victims" {
  name                          = "${var.prefix}-DCNet-to-VictimsNet"
  location                      = var.location
  resource_group_name           = local.resource_group_name
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "dc-2-victims" {
  name                = "${var.prefix}-dc-to-victimNet-${count.index}"
  resource_group_name = local.resource_group_name
  route_table_name    = azurerm_route_table.dc-2-victims.name
  address_prefix      = local.subnet_address_prefix[count.index]
  next_hop_type       = "vnetlocal"
  count               = var.num_of_labs
}

resource "azurerm_route_table" "victims-2-dc" {
  name                          = "${var.prefix}-VictimsNet-to-DCNet"
  location                      = var.location
  resource_group_name           = local.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "${var.prefix}-victim-to-dc"
    address_prefix = "10.10.98.0/24"
    next_hop_type  = "vnetlocal"
  }

}

resource "azurerm_subnet_route_table_association" "victims-2-dc" {
  count          = var.num_of_labs
  subnet_id      = azurerm_subnet.victim-subnets[count.index].id
  route_table_id = azurerm_route_table.victims-2-dc.id
}
