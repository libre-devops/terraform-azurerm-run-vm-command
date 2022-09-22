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
| [azurerm_virtual_machine_extension.linux_vm_file_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.linux_vm_inline_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.linux_vm_uri_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.windows_vm_file_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.windows_vm_inline_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.windows_vm_uri_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_resource_group.target_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_machine.azure_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_command"></a> [command](#input\_command) | A string Command to be executed. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of resources | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Specifies the operating system type. | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_script_file"></a> [script\_file](#input\_script\_file) | A path to a local file for the script | `string` | `null` | no |
| <a name="input_script_uri"></a> [script\_uri](#input\_script\_uri) | A URI for the script to be input raw | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the extension. | `map(any)` | `{}` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the virtual machine. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The ID of the VM you use in the module. |
