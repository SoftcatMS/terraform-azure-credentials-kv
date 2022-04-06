module "credentials" {
  source = "../../"

  key_vault_name           = "basic-kv"
  random_suffix            = true
  location                 = "uksouth"
  resource_group_name      = "password-basic-kv-rg"
  purge_protection_enabled = false

  passwords = [
    { name = "password1" },
    { name = "password2" }
  ]
}
