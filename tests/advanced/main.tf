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


# To be replaced with refacored VM Module
resource "azurerm_linux_virtual_machine" "test-adv" {
  name                       = "linux-sshkey-advanced-vm"
  location                   = azurerm_resource_group.rg-vm-password-advanced.location
  resource_group_name        = azurerm_resource_group.rg-vm-password-advanced.name
  network_interface_ids      = [azurerm_network_interface.test-adv.id]
  allow_extension_operations = false
  size                       = "Standard_B1ls"
  computer_name              = "linux-sshkey-advanced-vm"
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
  name                = "linux-sshkey-advanced-vm-nic"
  location            = azurerm_resource_group.rg-vm-password-advanced.location
  resource_group_name = azurerm_resource_group.rg-vm-password-advanced.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}


module "linuxserverspassword" {
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

