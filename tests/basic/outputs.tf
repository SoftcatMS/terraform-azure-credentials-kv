
output "passwords" {
  description = "A mapping of passwords names and URIs."
  value       = module.credentials.passwords
  sensitive   = true
}
