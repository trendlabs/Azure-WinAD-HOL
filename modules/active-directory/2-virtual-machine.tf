locals {
  virtual_machine_name = "dc01"
  virtual_machine_fqdn = "dc01.${var.active_directory_domain}"
  custom_data_params   = "Param($Prefix = \"${var.active_directory_netbios_name}\" $RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"dc01\")"
  custom_data_content  = "${local.custom_data_params} file(path.module/files/winrm.ps1)"
}

resource "azurerm_virtual_machine" "domain-controller" {
  name                          = local.virtual_machine_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.primary.id]
  # Switch VM sizing if you are on a FREE Azure Cloud subscription.
  vm_size                       = "Standard_B8ms"
  #vm_size                       = "Standard_B1ms"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.win_server_version.publisher // "MicrosoftWindowsServer"
    offer     = var.win_server_version.offer //"WindowsServer"
    sku       = var.win_server_version.sku //"2016-Datacenter"
    version   = var.win_server_version.version //"2016.127.20180613" //"latest"   
  }

  storage_os_disk {
    name              = "${local.virtual_machine_name}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "dc01"
    admin_username = var.domain_admin_username
    admin_password = var.domain_admin_password
    custom_data    = local.custom_data_content
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.domain_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.domain_admin_username}</Username></AutoLogon>"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/files/FirstLogonCommands.xml")
    }
  }

}
