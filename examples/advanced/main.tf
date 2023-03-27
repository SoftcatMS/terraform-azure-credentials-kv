resource "azurerm_resource_group" "rg-example-vms" {
  name     = "rg-example-vms-resources"
  location = "UK South"
}


module "credentials" {
  source = "github.com/SoftcatMS/terraform-azure-credentials-kv"

  key_vault_name                 = "My_Exiting_KeyVault"
  resource_group_name            = "My_Exiting_KeyVault_ResourceGroup"
  create_bastion_softcat_ssh_key = true
  bastion_softcat_ssh_key_name   = "Softcat-Bastion-Example"


  passwords = [
    { name = "linux-example-vm-1" },
    { name = "win-example-vm-2" },
    { name = "app-1" },
    { name = "db-1" }
  ]
}


module "linuxserverexample" {
  source                          = "github.com/SoftcatMS/terraform-azure-vm/modules/linux-vm"
  name                            = "linux-example-vm-1"
  resource_group_name             = azurerm_resource_group.rg-example-vms.name
  location                        = azurerm_resource_group.rg-example-vms.location
  virtual_machine_size            = "Standard_B1ls"
  disable_password_authentication = false
  admin_password                  = module.credentials.passwords["linux-example-vm-1"]
  enable_public_ip                = true
  public_ip_dns                   = "linuxpwdtestadvvmips" // change to a unique name per datacenter region
  vnet_subnet_id                  = module.vnet.vnet_subnets[0]
  enable_accelerated_networking   = false

  os_disk = [{
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }]

  source_image_publisher = "Canonical"
  source_image_offer     = "UbuntuServer"
  source_image_sku       = "16.04-LTS"
  source_image_version   = "latest"


  depends_on = [azurerm_resource_group.rg-kv-test-adv]
}


module "windowsserverexample2" {
  source              = "github.com/SoftcatMS/terraform-azure-vm"
  resource_group_name = azurerm_resource_group.rg-kv-test-adv.name
  vm_size             = "Standard_B1ls"
  vm_hostname         = "win-example-vm-2"
  admin_password      = module.credentials.passwords["win-example-vm-2"] # Output from terraform-azure-credentials-kv Module
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["windowspwdtestadvvmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  enable_ssh_key      = false

}

