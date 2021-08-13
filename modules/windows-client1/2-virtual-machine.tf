locals {
  virtual_machine_name = "${var.prefix}"
}

resource "azurerm_virtual_machine" "client" {
  name                          = local.virtual_machine_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.primary.id]
  # Switch VM sizing if you are on a FREE Azure Cloud subscription.
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.win_client_version.publisher // "MicrosoftWindowsDesktop"
    offer     = var.win_client_version.offer //"Windows-10"
    sku       = var.win_client_version.sku //"20h1-pro-g2"
    version   = var.win_client_version.version //"19041.985.2105050408" //"latest"
  }

  storage_os_disk {
    name              = "${local.virtual_machine_name}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = var.admin_username
    admin_password = var.admin_password

  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
  }
}
