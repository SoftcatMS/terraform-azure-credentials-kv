output "id" {
  description = "The ID of password Key Vault"
  value       = azurerm_key_vault.keyvault.id
}

output "passwords" {
  description = "A mapping of password names and URIs."
  value       = { for k, v in azurerm_key_vault_secret.add_password : v.name => v.value }
  sensitive   = true
}

output "softcat_public_ssh_key" {
  description = "Public key used to connect to VMs via Bastion."
  value       = tls_private_key.softcat_key.public_key_openssh
  sensitive   = true
}
