variable "key_vault_name" {
  type        = string
  description = "Key Vault Name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name for Key Vault"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "passwords" {
  description = "List resources that require a random password."
  type = list(object({
    name = string,
  }))
  default = []
}

variable "create_bastion_softcat_ssh_key" {
  description = "Create Softcat SSH key pair for Bastion"
  type        = bool
  default     = false
}


variable "bastion_softcat_ssh_key_name" {
  description = "Softcat SSH key for Bastion Name"
  type        = string
  default     = "Softcat-Bastion"
}
