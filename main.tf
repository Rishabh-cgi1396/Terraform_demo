terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # ⚠️ OPTIONAL BUT STRONGLY RECOMMENDED
  # Uncomment after creating storage account
  # backend "azurerm" {
  #   resource_group_name  = "tf-rg"
  #   storage_account_name = "tfstate12345"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# -------------------------------
# Resource Group
# -------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# -------------------------------
# VNET + SUBNET
# -------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -------------------------------
# MODULE CALL
# -------------------------------
module "linux_vm" {
  source = "./modules/linux-vm"

  vm_name             = var.vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id

  vm_size         = var.vm_size
  admin_username  = var.admin_username
  ssh_public_key  = var.ssh_public_key
  create_public_ip = var.create_public_ip
  create_nsg       = var.create_nsg

  image = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts-gen2"
    version   = "latest"
  }
}
