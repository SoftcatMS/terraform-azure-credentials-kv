module "credentials" {
  source = "../../"

  key_vault_name           = "password-adv-kv"
  random_suffix            = false
  location                 = "uksouth"
  resource_group_name      = "password-advanced-kv-rg"
  purge_protection_enabled = false

  passwords = [
    { name = "password1" },
    { name = "password2" },
    { name = "web-2" },
  ]

}


resource "azurerm_resource_group" "rg-vm-password-advanced" {
  name     = "rg-password-advanced-vm-resources"
  location = "UK South"
}

module "vnet" {

  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-password-advanced"
  resource_group_name = azurerm_resource_group.rg-vm-password-advanced.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24"]
  subnet_names        = ["subnet1"]

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg-vm-password-advanced]
}

module "linuxservers" {
  source              = "github.com/SoftcatMS/terraform-azure-vm"
  resource_group_name = azurerm_resource_group.rg-vm-password-advanced.name
  vm_size             = "Standard_B1ls"
  vm_hostname         = "linux-password-advanced-vm"
  admin_password      = module.credentials.passwords["web-2"]
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linuxtestpasswordadvvmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  enable_ssh_key      = false

  depends_on = [azurerm_resource_group.rg-vm-password-advanced]
}
