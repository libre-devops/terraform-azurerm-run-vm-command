module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name     = "vnet-${var.short}-${var.loc}-${terraform.workspace}-01" // vnet-ldo-euw-dev-01
  vnet_location = module.network.vnet_location

  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names    = ["sn1-${module.network.vnet_name}", "sn2-${module.network.vnet_name}", "sn3-${module.network.vnet_name}"] //sn1-vnet-ldo-euw-dev-01
  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage"]                   // Adds extra subnet endpoints to sn1-vnet-ldo-euw-dev-01
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Sql"], // Adds extra subnet endpoints to sn2-vnet-ldo-euw-dev-01
    "sn3-${module.network.vnet_name}" = ["Microsoft.AzureActiveDirectory"]      // Adds extra subnet endpoints to sn3-vnet-ldo-euw-dev-01
  }
}

module "nsg" {
  source = "registry.terraform.io/libre-devops/nsg/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name  = "nsg-${var.short}-${var.loc}-${terraform.workspace}-01"
  subnet_id = element(values(module.network.subnets_ids), 0)
}

module "bastion" {
  source = "registry.terraform.io/libre-devops/bastion/azurerm"


  vnet_rg_name = module.network.vnet_rg_name
  vnet_name    = module.network.vnet_name

  bas_subnet_iprange = "10.0.4.0/26"

  bas_nsg_name     = "nsg-bas-${var.short}-${var.loc}-${terraform.workspace}-01"
  bas_nsg_location = module.rg.rg_location
  bas_nsg_rg_name  = module.rg.rg_name

  bas_pip_name              = "pip-bas-${var.short}-${var.loc}-${terraform.workspace}-01"
  bas_pip_location          = module.rg.rg_location
  bas_pip_rg_name           = module.rg.rg_name
  bas_pip_allocation_method = "Static"
  bas_pip_sku               = "Standard"

  bas_host_name          = "bas-${var.short}-${var.loc}-${terraform.workspace}-01"
  bas_host_location      = module.rg.rg_location
  bas_host_rg_name       = module.rg.rg_name
  bas_host_ipconfig_name = "bas-${var.short}-${var.loc}-${terraform.workspace}-01-ipconfig"

  tags = module.rg.rg_tags
}

module "lnx_vm" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location

  vm_amount          = 1
  vm_hostname        = "lnx${var.short}${var.loc}${terraform.workspace}"
  vm_size            = "Standard_B2ms"
  vm_os_simple       = "Ubuntu22.04"
  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0)
  availability_zone    = "alternate"
  storage_account_type = "Standard_LRS"
  identity_type        = "SystemAssigned"

  tags = module.rg.rg_tags
}

module "run_command_lnx" {
  source = "registry.terraform.io/libre-devops/run-vm-command/azurerm"

  depends_on = [module.lnx_vm] // fetches as a data reference so requires depends-on
  location   = module.rg.rg_location
  rg_name    = module.rg.rg_name
  tags       = module.rg.rg_tags

  vm_name = element(module.lnx_vm.vm_name, 0)
  os_type = "linux"

  script_uri = "https://raw.githubusercontent.com/libre-devops/terraform-azurerm-run-vm-command/main/terraform/test-script.sh"
}

#// Default behaviour uses "registry.terraform.io/libre-devops/windows-os-plan-calculator/azurerm"
#module "win_vm" {
#  source = "registry.terraform.io/libre-devops/windows-vm/azurerm"
#
#  rg_name  = module.rg.rg_name
#  location = module.rg.rg_location
#  tags     = module.rg.rg_tags
#
#  vm_amount          = 1
#  vm_hostname        = "win${var.short}${var.loc}${terraform.workspace}" // winldoeuwdev01 & winldoeuwdev02 & winldoeuwdev03
#  vm_size            = "Standard_D4s_v3"
#  use_simple_image   = true
#  vm_os_simple       = "WindowsServer2019"
#  vm_os_disk_size_gb = "127"
#
#  asg_name = "asg-${element(regexall("[a-z]+", element(module.win_vm_simple.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string
#
#  admin_username = "LibreDevOpsAdmin"
#  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value // Created with the Libre DevOps Terraform Pre-Requisite script
#
#  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
#  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
#  storage_account_type = "Standard_LRS"
#  identity_type        = "SystemAssigned"
#}
#
#module "run_command_win" {
#  source = "registry.terraform.io/libre-devops/run-vm-command/azurerm"
#
#  depends_on = [module.win_vm] // fetches as a data reference so requires depends-on
#  location   = module.rg.rg_location
#  rg_name    = module.rg.rg_name
#  tags       = module.rg.rg_tags
#
#  vm_name = element(module.win_vm.vm_name, 0)
#  os_type = "windows"
#
#  command = "apt-get update && apt-get dist-upgrade -y && apt-get install git unzip zip curl gcc dos2unix jq -y && apt-get autoclean && exit 0"
#}