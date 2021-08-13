locals {

test_script = <<EOF

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1 | Out-File -FilePath C:\${var.active_directory_netbios_name}\NoAutoUpdate.txt

Remove-WindowsFeature Windows-Defender, Windows-Defender-GUI
Set-NetFirewallProfile -All -Enabled False
ping 1.1.1.1
Set-DnsServerForwarder -IPAddress 1.1.1.1
Add-DnsServerPrimaryZone -NetworkID "10.10.98.0/24" -ReplicationScope "Forest"
Add-DnsServerResourceRecordPtr -Name 10 -ZoneName "98.10.10.in-addr.arpa" -PtrDomainName "dc01.${var.active_directory_domain}"

Set-TimeZone -Name "${var.local_time}"

$domain = "${var.active_directory_domain}"
$arr = $domain.split(".")

$password = ConvertTo-SecureString '${var.domain_admin_password}' -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential("$($arr[0])\${var.domain_admin_username}", $password)

New-ADOrganizationalUnit -Server $domain -Name "UserAccounts" -Credential $Cred

$OUpath = "OU=UserAccounts,DC=$($arr[0]),DC=$($arr[1])"

$user_list = '${join(" ",var.domain_usernames[*].internal_domain_username)}'
$user_array=$user_list.split(" ")

ForEach ($u in $user_array) {
 $givenName = $u.split(".")[0]
 $surName = $u.split(".")[1]
 $fullName = "$($givenName) $($surName)"
 New-ADUser -path $OUpath -Name $fullName -GivenName $givenName -Surname $surName -SamAccountName "$u" -UserPrincipalName "$u@$($domain)" -Department "Tech-Support" -Enabled $true -AccountPassword (ConvertTo-SecureString "${var.domain_user_password}" -AsPlainText -Force) -PasswordNeverExpires $true -Company "TrendLabs" -Title "Engineer" -Email "$u@$($domain)" -Credential $Cred
}

Restart-Computer
EOF
  settings_windows = {
    script   = compact(concat(split("\n", local.test_script)))
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
depends_on = [time_sleep.wait-for-dc]
}

data "azurerm_virtual_machine" "main" {
  name                = azurerm_virtual_machine.domain-controller.name
  resource_group_name = data.azurerm_resource_group.main.name
depends_on = [time_sleep.wait-for-dc]
}

resource "azurerm_virtual_machine_extension" "init-server" {
  name                       = "${var.prefix}-run-command"
  virtual_machine_id       = data.azurerm_virtual_machine.main.id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.settings_windows)

depends_on = [time_sleep.wait-for-dc]
}
