variable "rg_name" {
  type        = string
  description = "Resource group for compute resources."
}

variable "location" {
  type        = string
  description = "Azure location."
}

variable "prefix" {
  type        = string
  description = "Name prefix."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

variable "subnet_ids" {
  type        = map(string)
  description = "Subnet IDs from the network module."
}

variable "nsg_ids" {
  type        = map(string)
  description = "NSG IDs from the network module."
}

variable "admin_username" {
  type        = string
  description = "Linux VM admin username."
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key value."
}

variable "vm1_size" {
  type        = string
  description = "VM size for VM1."
  default     = "Standard_B1s"
}

variable "vm2_size" {
  type        = string
  description = "VM size for VM2."
  default     = "Standard_B1ms"
}

variable "enable_bastion" {
  type        = bool
  description = "Enable Azure Bastion deployment."
  default     = false
}

variable "enable_vmss" {
  type        = bool
  description = "Enable VM Scale Set deployment."
  default     = false
}
