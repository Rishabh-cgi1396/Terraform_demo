variable "vm_name" {}
variable "location" {}
variable "resource_group_name" {}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_public_key" {}

variable "create_public_ip" {
  default = true
}

variable "create_nsg" {
  default = true
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
