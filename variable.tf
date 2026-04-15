variable "vm_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}

variable "vm_size" {}
variable "admin_username" {}
variable "ssh_public_key" {}

variable "create_public_ip" {}
variable "create_nsg" {}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
