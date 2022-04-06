resource "azurerm_resource_group" "kv-rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}


#Create KeyVault ID
resource "random_string" "unique" {
  length  = 4
  special = false
}

locals {
  suffix = var.random_suffix ? random_string.unique.result : ""
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  #checkov:skip=CKV_AZURE_42:Ensure the key vault is recoverable 
  #checkov:skip=CKV_AZURE_109:Ensure key vault allows firewall rules settings 
  #checkov:skip=CKV_AZURE_110:Ensure that key vault enables purge protection 
  depends_on                  = [azurerm_resource_group.kv-rg]
  name                        = lower(join("", [var.key_vault_name, (local.suffix)]))
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.purge_protection_enabled
  soft_delete_enabled         = true
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = data.azurerm_client_config.current.object_id

  #   key_permissions = [
  #     "Get",
  #   ]

  #   secret_permissions = [
  #     "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
  #   ]

  #   storage_permissions = [
  #     "Get",
  #   ]
  # }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? ["true"] : []
    content {
      default_action             = var.network_acls.default_action
      bypass                     = var.network_acls.bypass
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.subnet_ids
    }
  }

  tags = var.tags
}


resource "azurerm_role_assignment" "role-secret-officer" {
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.keyvault.id
}

resource "tls_private_key" "softcat_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_key_vault_secret" "add_softcat_private_key" {
  #checkov:skip=CKV_AZURE_41:Ensure AKV secrets have an expiration date set
  name         = "Softcat-Bastion-Private-Key"
  value        = tls_private_key.softcat_key.private_key_openssh
  content_type = "ssh-key"
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_key_vault.keyvault]

  lifecycle {
    ignore_changes = [value] #Ignore so that key can be handled via console. This is used fo rinitial deployment
  }

}

resource "azurerm_key_vault_secret" "add_softcat_public_key" {
  #checkov:skip=CKV_AZURE_41:Ensure AKV secrets have an expiration date set
  name         = "Softcat-Bastion-Public-Key"
  value        = tls_private_key.softcat_key.public_key_openssh
  content_type = "ssh-key"
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_key_vault.keyvault]

  lifecycle {
    ignore_changes = [value] #Ignore so that key can be handled via console. This is used fo rinitial deployment
  }

}

resource "random_password" "gen_password" {
  count   = length(var.passwords)
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "add_password" {
  #checkov:skip=CKV_AZURE_41:Ensure AKV secrets have an expiration date set
  count        = length(var.passwords)
  name         = var.passwords[count.index].name
  value        = random_password.gen_password[count.index].result
  content_type = "password"
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_key_vault.keyvault]

}

