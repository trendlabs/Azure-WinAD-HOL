resource "time_sleep" "wait-for-setup" {

  depends_on = [azurerm_virtual_machine_extension.join-domain]
  create_duration = "60s"

}

resource "time_sleep" "wait-jump-for-setup" {

  create_duration = "300s"

  count = (var.jump_host) ? 1 : 0
}

locals{

test_script = <<EOF

$domain = "${var.active_directory_domain}"
New-Item -itemtype directory -path "c:\" -name "lab-guide"
Set-TimeZone -Name "${var.local_time}"
Set-NetFirewallProfile -All -Enabled False

"${var.apex_agent}" | Out-File -FilePath C:\lab-guide\lab-guide.txt
"install ApexOne in the other VM below" | Out-File -FilePath C:\lab-guide\lab-guide.txt -Append
"- Account to login to ${azurerm_network_interface.primary.private_ip_address} is ${var.active_directory_netbios_name}\${var.admin_username}" | Out-File -FilePath C:\lab-guide\lab-guide.txt -Append
"- Password is ${var.admin_password}" | Out-File -FilePath C:\lab-guide\lab-guide.txt -Append
"Domain Controller IP: 10.10.98.10" | Out-File -FilePath C:\lab-guide\lab-guide.txt -Append

$progressPreference = "silentlyContinue"
Invoke-Expression "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
Invoke-WebRequest -Uri "https://github.com/trendlabs/demo/raw/main/MITRE-master.zip" -Outfile "C:\lab-guide\MITRE-master.zip"

$jump_host = "${var.jump_host}"
if ( "false" -eq $jump_host )
{
  Add-LocalGroupMember -Group "Administrators" -Member "${var.active_directory_netbios_name}\${var.admin_username}"
}

Invoke-WebRequest -Uri ${var.apex_agent} -Outfile "C:\lab-guide\agent_x64.msi"
Set-ExecutionPolicy Allsigned; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y --ignore-checksum

EOF
  settings_windows = {
    script   = compact(concat(split("\n", local.test_script)))
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
  depends_on = [time_sleep.wait-for-setup]
}

data "azurerm_virtual_machine" "main" {
  name                = azurerm_virtual_machine.client.name
  resource_group_name = data.azurerm_resource_group.main.name
  depends_on = [time_sleep.wait-for-setup]
}

resource "azurerm_virtual_machine_extension" "init-client" {

  name                       = "${var.prefix}-init-client"

  virtual_machine_id       = data.azurerm_virtual_machine.main.id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.settings_windows)

  depends_on = [time_sleep.wait-for-setup]
  count = (var.jump_host) ? 0 : 1
}

resource "azurerm_virtual_machine_extension" "init-jump" {
  name                       = "${var.prefix}-init-jump"

  virtual_machine_id       = azurerm_virtual_machine.client.id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.settings_windows)

  depends_on = [time_sleep.wait-jump-for-setup]

  count = (var.jump_host) ? 1 : 0
}
