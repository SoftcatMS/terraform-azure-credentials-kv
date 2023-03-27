# terraform-azure-credentials-kv

Allows creation of a list of secrets in an existing Azure Key Vault

It supports creating:

- Automatically creates Softcat SSH Key
- Secrets 


## Usage Examples
Review the examples folder: [examples](./examples)


## Deployment
Perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure


< use terraform-docs to create Inputs and Outpus documentation  [terraform-docs](https://github.com/terraform-docs/terraform-docs)

`terraform-docs markdown .`


## Requirements
### Installed Software
The following dependencies must be installed on the development system:

- [Terraform](https://www.terraform.io/downloads.html) 

Azure  
- [Terraform Provider for Azure](https://github.com/hashicorp/terraform-provider-azurerm)
- CLI Tool [az](https://docs.microsoft.com/en-us/cli/azure/)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.add_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.add_softcat_private_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.add_softcat_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_password.gen_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.softcat_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_key_vault.softcat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_softcat_ssh_key_name"></a> [bastion\_softcat\_ssh\_key\_name](#input\_bastion\_softcat\_ssh\_key\_name) | Softcat SSH key for Bastion Name | `string` | `"Softcat-Bastion"` | no |
| <a name="input_create_bastion_softcat_ssh_key"></a> [create\_bastion\_softcat\_ssh\_key](#input\_create\_bastion\_softcat\_ssh\_key) | Create Softcat SSH key pair for Bastion | `bool` | `false` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key Vault Name. | `string` | n/a | yes |
| <a name="input_passwords"></a> [passwords](#input\_passwords) | List resources that require a random password. | <pre>list(object({<br>    name = string,<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group Name for Key Vault | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_passwords"></a> [passwords](#output\_passwords) | A mapping of password names and URIs. |
| <a name="output_softcat_public_ssh_key"></a> [softcat\_public\_ssh\_key](#output\_softcat\_public\_ssh\_key) | Public key used to connect to VMs via Bastion. |


## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for information on contributing to this module.
