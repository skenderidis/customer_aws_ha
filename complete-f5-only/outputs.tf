# BIG-IP Management Public DNS Address
output "mgmtPublicIP_01" {
  value = module.bigip_ha_1.mgmtPublicDNS
}
output "mgmtPublicIP_02" {
  value = module.bigip_ha_2.mgmtPublicDNS
}


output "private_addresses_1" {
  description = "List of BIG-IP private addresses"
  value       = module.bigip_ha_1.*.private_addresses
}

output "private_addresses_2" {
  description = "List of BIG-IP private addresses"
  value       = module.bigip_ha_2.*.private_addresses
}

 output tls_privatekey {
   value = tls_private_key.f5_key.private_key_pem
   sensitive = true
 }