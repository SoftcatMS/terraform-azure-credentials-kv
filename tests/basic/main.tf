resource "azurerm_resource_group" "rg-kv-test-basic" {
  name     = "rg-test-kv-basic-resources"
  location = "UK South"
}

module "credentials" {
  source = "../../"

  key_vault_name           = "basic-kv"
  random_suffix            = true
  location                 = "uksouth"
  resource_group_name      = azurerm_resource_group.rg-kv-test-basic.name
  purge_protection_enabled = false

  passwords = [
    { name = "password1" },
    { name = "password2" }
  ]

  depends_on = [azurerm_resource_group.rg-kv-test-basic]


}
