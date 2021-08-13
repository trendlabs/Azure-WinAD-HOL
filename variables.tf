variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "num_of_labs" {
  type = number
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "master_domain" {
  type = string
}

variable "domain_user_password" {
  type = string
}

variable "domain_admin_username" {
  type = string
}
variable "domain_admin_password" {
  type = string
}

variable "apex_agent" {
  type = string
}

variable "prefix" {
  type = string
}

variable "win_server_version" {
  type = map
}

variable "win_client_version" {
  type = map
}

variable "local_time" {
  type = string
}

variable "users" {
  type = list(map(string))
  default = []
}
