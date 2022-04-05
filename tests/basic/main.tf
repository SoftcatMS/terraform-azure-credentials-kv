module "credentials" {
  source = "../../"

  key_vault_name           = "password-basic-kv"
  random_suffix            = false
  location                 = "uksouth"
  resource_group_name      = "password-basic-kv-rg"
  purge_protection_enabled = false

  passwords = [
    { name = "password1" },
    { name = "password2" }
  ]
}
