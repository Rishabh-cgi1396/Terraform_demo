vm_name             = "dev-vm"
location            = "Central India"
resource_group_name = "vm-rg-dev"
admin_username = "azureuser"

vm_size = "Standard_B1s"

# OPTION A (LOCAL)
ssh_public_key = file("~/.ssh/azure_key.pub")
