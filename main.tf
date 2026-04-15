#####################################
# Provider
#####################################
provider "azurerm" {
  features {}
}

#####################################
# Resource Group
#####################################
resource "azurerm_resource_group" "rg" {
  name     = "vm-rg"
  location = "North Europe"
}

#####################################
# Virtual Network
#####################################
resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#####################################
# Subnet
#####################################
resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#####################################
# Public IP
#####################################
resource "azurerm_public_ip" "pip" {
  name                = "vm1-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#####################################
# Network Interface
#####################################
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

#####################################
# Linux VM (Exact match)
#####################################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  zone                = "1"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa.pub")
  }

  #####################################
  # Trusted Launch (matches portal)
  #####################################
  secure_boot_enabled = true
  vtpm_enabled        = true

  #####################################
  # OS Disk
  #####################################
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  #####################################
  # Image (Ubuntu Pro 24.04 Gen2)
  #####################################
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-pro-jammy"
    sku       = "pro-24_04-lts-gen2"
    version   = "latest"
  }

  #####################################
  # Boot diagnostics (enabled)
  #####################################
  boot_diagnostics {}
}
