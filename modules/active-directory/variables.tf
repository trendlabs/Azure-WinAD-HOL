variable "resource_group_name" {
  description = "The name of the Resource Group where the Domain Controllers resources will be created"
}

variable "location" {
  description = "The Azure Region in which the Resource Group exists"
}

variable "prefix" {
  description = "The Prefix used for the Domain Controller's resources"
}

variable "subnet_id" {
  description = "The Subnet ID which the Domain Controller's NIC should be created in"
}


variable "domain_admin_username" {
  description = "The username associated with the local administrator account on the virtual machine"
}

variable "domain_admin_password" {
  description = "The password associated with the local administrator account on the virtual machine"
}

variable "dc_private_ip" {
  description = "DC Server Static private IP address"
}

variable "vm_size" {}

variable "active_directory_domain" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "active_directory_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "domain_user_password" {
  description = "The password associated with the user accounts in domain"
}

variable "domain_usernames" {
  description = "The usernames associated with the user accounts in domain"
  type = list(map(string))
  default = []
}

variable "win_server_version" {
  type = map
}

variable "local_time" {}
