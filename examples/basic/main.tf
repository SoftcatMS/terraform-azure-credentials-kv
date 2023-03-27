module "credentials" {
  source = "github.com/SoftcatMS/terraform-azure-credentials-kv"

  key_vault_name                 = "My_Exiting_KeyVault"
  resource_group_name            = "My_Exiting_KeyVault_ResourceGroup"
  create_bastion_softcat_ssh_key = true
  bastion_softcat_ssh_key_name   = "Softcat-Bastion"


  passwords = [
    { name = "web-1" },
    { name = "app-1" },
    { name = "db-1" }
  ]
}
