resource "azurerm_resource_group" "rg-kv-test-adv" {
  name     = "rg-test-kv-adv-resources"
  location = "UK South"
}

#Create KeyVault ID
resource "random_string" "unique" {
  length  = 5
  special = false
  number  = true
}

locals {
  suffix = random_string.unique.result
}

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "kv-test-adv" {
  #checkov:skip=CKV_AZURE_42:Ensure the key vault is recoverable 
  #checkov:skip=CKV_AZURE_109:Ensure key vault allows firewall rules settings 
  #checkov:skip=CKV_AZURE_110:Ensure that key vault enables purge protection 
  #checkov:skip=CKV_AZURE_111:Ensure that key vault enables soft delete
  name                        = "kv-test-adv"
  resource_group_name         = azurerm_resource_group.rg-kv-test-adv.name
  location                    = azurerm_resource_group.rg-kv-test-adv.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  soft_delete_enabled         = false
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

  key_vault_name      = azurerm_key_vault.kv-test-adv.name
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name

  passwords = [
    { name = "password1" },
    { name = "password2" },
    { name = "web-2" }

  ]

  depends_on = [azurerm_key_vault.kv-test-adv]

}


module "vnet" {

  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-kv-test-adv"
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24"]
  subnet_names        = ["subnet1"]

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg-kv-test-adv]
}


# To be replaced with refactored VM Module
resource "azurerm_linux_virtual_machine" "test-adv" {
  name                       = "linux-sshkey-test-adv-vm"
  location                   = azurerm_resource_group.rg-kv-test-adv.location
  resource_group_name        = azurerm_resource_group.rg-kv-test-adv.name
  network_interface_ids      = [azurerm_network_interface.test-adv.id]
  allow_extension_operations = false
  size                       = "Standard_B1ls"
  computer_name              = "linux-sshkey-test-adv-vm"
  admin_username             = "azure_user"

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure_user"
    public_key = module.credentials.softcat_public_ssh_key
  }

  os_disk {
    name                 = "os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_network_interface" "test-adv" {
  name                = "linux-sshkey-test-adv-vm-nic"
  location            = azurerm_resource_group.rg-kv-test-adv.location
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}


module "linuxserverspassword" {
  source              = "github.com/SoftcatMS/terraform-azure-vm"
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name
  vm_size             = "Standard_B1ls"
  vm_hostname         = "linux-password-test-adv-vm"
  admin_password      = module.credentials.passwords["web-2"]
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linuxpwdtestadvvmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  enable_ssh_key      = false

  depends_on = [azurerm_resource_group.rg-kv-test-adv]
}

