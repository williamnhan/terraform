# output "bastion_host_subnet_us2w" {
#   value = module.locations_us2w.bastion_host_subnet.id
# }
# output "bastion_host_subnet_us2e" {
#   value = module.location_us2e.bastion_host_subnet
# }

output "bastion_host_subnet_us2w" {
  value = module.locations["us2w"].bastion_host_subnet.id
}
output "all" {
  value = module.locations
}