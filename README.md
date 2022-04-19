# Run Commmand in Azure VM

Uses the VM agent to run PowerShell scripts (Windows) or shell scripts (Linux) within an Azure VM. It can be used to bootstrap/install software or run administrative tasks.

The module version matches the version of terraform it is intended to work with.

This means this script is purely to bootstrap something where you want a one time execution, e.g. `sudo yum update -y`, or to install a tool or open a firewall port after the VM has been built.

## Tips

- Ensure you always include some form of logging into your script, such as the `--log-file` paramter to `chocolatey`
- Try to create a failure state where you always exit with exit 1 for a failure or exit 0 for success, this will help the module not return false positives.

## Example Usage

```hcl
module "win_vm" {
  source = "registry.terraform.io/libre-devops/windows-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location

  vm_amount          = 3
  vm_hostname        = "win${var.short}${var.loc}${terraform.workspace}" // winldoeuwdev01 & winldoeuwdev02 & winldoeuwdev03
  vm_size            = "Standard_B2ms"
  vm_os_simple       = "WindowsServer2019"
  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.win_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value // Created with the Libre DevOps Terraform Pre-Requisite script

  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
  storage_account_type = "Standard_LRS"
  identity_type        = "SystemAssigned"

  tags = module.rg.rg_tags
}

module "run_command_win" {
  source = "registry.terraform.io/libre-devops/run-vm-command/azurerm"

  depends_on = [module.win_vm] // fetches as a data reference so requires depends-on
  location   = module.rg.rg_location
  rg_name    = module.rg.rg_name
  vm_name    = element(module.win_vm.vm_name, 0)
  os_type    = "windows"
  tags       = module.rg.rg_tags

  command = "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) ; choco install -y git" // Runs this commands on winldoeuwdev01
}

module "lnx_vm" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location

  vm_amount          = 2
  vm_hostname        = "lnx${var.short}${var.loc}${terraform.workspace}" // lmxldoeuwdev01 & lmxldoeuwdev02
  vm_size            = "Standard_B2ms"
  vm_os_simple       = "Ubuntu20.04"
  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-lnxldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key // Created with the Libre DevOps Terraform Pre-Requisite Script

  subnet_id            = element(values(module.network.subnets_ids), 0)
  availability_zone    = "alternate"
  storage_account_type = "Standard_LRS"
  identity_type        = "SystemAssigned"

  tags = module.rg.rg_tags
}

module "run_command_lnx" {
  source = "registry.terraform.io/libre-devops/run-vm-command/azurerm"

  for_each = {
    for key, value in module.lnx_vm.vm_name : key => value
  }

  depends_on = [module.lnx_vm] // fetches as a data reference so requires depends-on
  location   = module.rg.rg_location
  rg_name    = module.rg.rg_name
  vm_name    = each.value
  os_type    = "linux"
  tags       = module.rg.rg_tags

  command = "echo hello > /home/libre-devops.txt" // Runs this commands on all Linux VMs
}

```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.linux_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.windows_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_resource_group.target_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_machine.azure_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_command"></a> [command](#input\_command) | A string Command to be executed. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of resources | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Specifies the operating system type. | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the extension. | `map(any)` | `{}` | no |
| <a name="input_timestamp"></a> [timestamp](#input\_timestamp) | Intended to trigger re-execution of the script when changed. | `string` | `""` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the virtual machine. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The ID of the VM you use in the module. |
