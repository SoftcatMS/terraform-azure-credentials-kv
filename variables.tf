variable "key_vault_name" {
  type        = string
  description = "Key Vault Name."
}

variable "random_suffix" {
  description = "Boolean flag which controls if random string appened to name."
  type        = bool
  default     = false
}


variable "resource_group_name" {
  type        = string
  description = "Resource Group Name for Key Vault"
}

variable "location" {
  type        = string
  description = "Location for Key Vault"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Is Purge Protection enabled for this Key Vault? Defaults to true"
  default     = true
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

variable "network_acls" {
  description = "Network rules restricing access to the key vault."
  type        = object({ default_action = string, bypass = string, ip_rules = list(string), subnet_ids = list(string) })
  default = {
    default_action = "Allow"
    bypass         = "AzureServices",
    ip_rules       = [],
    subnet_ids     = []
  }
}
