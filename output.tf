output "jump_host_public_ip_addresses" {
  value = module.lab-jump-host.*.public_ip_address
}

output "victim_private_ip_address" {
  value = module.lab-victim-1.*.private_ip_address
}
