
module "credentials" {
  source = "github.com/SoftcatMS/terraform-azure-credentials-kv"

  key_vault_name      = "My_Exiting_KeyVault"
  resource_group_name = "My_Exiting_KeyVault_ResourceGroup"
  passwords = [
    { name = "web-1" },
    { name = "web-2" },
    { name = "app-1" },
    { name = "db-1" }
  ]
}

# This example needs to be updated to Softcat VM module once VM Module refactored (26/04/22)
resource "azurerm_linux_virtual_machine" "test-adv" {
  name                       = "web-1"
  location                   = "uksouth"
  resource_group_name        = "my_resource_group_name"
  network_interface_ids      = "nic_id"
  allow_extension_operations = false
  size                       = "Standard_B1ls"
  computer_name              = "web-1"
  admin_username             = "azure_user"

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azure_user"
    public_key = module.credentials.softcat_public_ssh_key # Default output from terraform-azure-credentials-kv Module
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
  name                = "web-2-nic"
  location            = azurerm_resource_group.rg-kv-test-adv.location
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}


module "web-2" {
  source              = "github.com/SoftcatMS/terraform-azure-vm"
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name
  vm_size             = "Standard_B1ls"
  vm_hostname         = "web-2"
  admin_password      = module.credentials.passwords["web-2"] # Output from terraform-azure-credentials-kv Module
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linuxpwdtestadvvmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  enable_ssh_key      = false

}

