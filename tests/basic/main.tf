resource "azurerm_resource_group" "rg-kv-test-basic" {
  name     = "rg-test-kv-basic-resources"
  location = "UK South"
}

#Create KeyVault ID
# resource "random_string" "unique" {
#   length  = 5
#   special = false
#   number  = true
# }

# locals {
#   suffix = random_string.unique.result
# }

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "kv-test-basic" {
  #checkov:skip=CKV_AZURE_42:Ensure the key vault is recoverable 
  #checkov:skip=CKV_AZURE_109:Ensure key vault allows firewall rules settings 
  #checkov:skip=CKV_AZURE_110:Ensure that key vault enables purge protection 
  #checkov:skip=CKV_AZURE_111:Ensure that key vault enables soft delete
  name                        = "kv-test-basic"
  resource_group_name         = azurerm_resource_group.rg-kv-test-basic.name
  location                    = azurerm_resource_group.rg-kv-test-basic.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }
}


module "credentials" {
  source = "../../"

  key_vault_name      = azurerm_key_vault.kv-test-basic.name
  resource_group_name = azurerm_resource_group.rg-kv-test-basic.name

  passwords = [
    { name = "password1" },
    { name = "password3" }
  ]

  depends_on = [azurerm_key_vault.kv-test-basic]

}
