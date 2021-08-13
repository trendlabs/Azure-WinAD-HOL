resource "azurerm_public_ip" "static" {
  name                         = "${var.prefix}-jump-ppip"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method = "Static"
  count = (var.jump_host) ? 1 : 0
}

resource "azurerm_network_interface" "primary" {
  name                    = "${var.prefix}-nic"
  location                = var.location
  resource_group_name     = var.resource_group_name
  internal_dns_name_label = local.virtual_machine_name

  dns_servers             = [ var.dc_private_ip ]
  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = (var.jump_host) ? azurerm_public_ip.static[0].id:""
  }
}
