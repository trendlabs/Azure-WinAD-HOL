variable "resource_group_name" {
  description = "The name of the Resource Group where the Windows Client resources will be created"
}

variable "location" {
  description = "The Azure Region in which the Resource Group exists"
}

variable "prefix" {
  description = "The Prefix used for the Windows Client resources"
}

variable "subnet_id" {
  description = "The Subnet ID which the Windows Client's NIC should be created in"
}

variable "admin_username" {
  description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
  description = "The password associated with the local administrator account on the virtual machine"
}
variable "networksec_group"{
  description = "Security group"
}

variable "jump_host"{
  description = "Specify if the generated is a jump_host"
}

variable "dc_private_ip" {
  description = "DC Server Static private IP address"
}

variable "active_directory_domain" {
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "active_directory_username" {
  description = "The username of an account with permissions to bind machines to the Active Directory Domain"
}

variable "active_directory_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "active_directory_password" {
  description = "The password of the account with permissions to bind machines to the Active Directory Domain"
}

variable "domain_user_password" {
  description = "The password associated with the user account in domain"
}

variable "vm_size" {}

variable "apex_agent" {}

variable "win_client_version" {
  type = map
}

variable "local_time" {}
