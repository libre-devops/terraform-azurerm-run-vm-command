data "azurerm_resource_group" "target_rg" {
  name = var.rg_name
}

data "azurerm_virtual_machine" "azure_vm" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.target_rg.name
}