data "azurerm_key_vault" "softcat" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
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
  key_vault_id = data.azurerm_key_vault.softcat.id

  depends_on = [tls_private_key.softcat_key]

  lifecycle {
    ignore_changes = [value] #Ignore so that key can be handled via console. This is used for initial deployment
  }
}

resource "azurerm_key_vault_secret" "add_softcat_public_key" {
  #checkov:skip=CKV_AZURE_41:Ensure AKV secrets have an expiration date set
  name         = "Softcat-Bastion-Public-Key-1"
  value        = tls_private_key.softcat_key.public_key_openssh
  content_type = "ssh-key"
  key_vault_id = data.azurerm_key_vault.softcat.id

  depends_on = [tls_private_key.softcat_key]

  lifecycle {
    ignore_changes = [value] #Ignore so that key can be handled via console. This is used fo rinitial deployment
  }
}

resource "random_password" "gen_password" {
  count            = length(var.passwords)
  length           = 20
  min_lower        = 1
  min_upper        = 1
  special          = true
  override_special = "!#$%*-_=+"
}

resource "azurerm_key_vault_secret" "add_password" {
  #checkov:skip=CKV_AZURE_41:Ensure AKV secrets have an expiration date set
  count        = length(var.passwords)
  name         = var.passwords[count.index].name
  value        = random_password.gen_password[count.index].result
  content_type = "password"
  key_vault_id = data.azurerm_key_vault.softcat.id

  depends_on = [random_password.gen_password]

  lifecycle {
    ignore_changes = [value]
  }
}
