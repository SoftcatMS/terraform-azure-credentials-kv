
output "passwords" {
  description = "A mapping of passwords names and URIs."
  value       = module.credentials.passwords
  sensitive   = true
}

output "public_key" {
  description = "Public Key Value."
  value       = module.credentials.softcat_public_ssh_key
  sensitive   = true
}
