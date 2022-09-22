resource "azurerm_virtual_machine_extension" "linux_vm_inline_command" {
  count                      = lower(var.os_type) == "linux" && try(var.script_file, null) == null && try(var.command, null) != null ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    commandToExecute = tostring(var.command)
  })

  tags               = var.tags
  virtual_machine_id = data.azurerm_virtual_machine.azure_vm.id

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_virtual_machine_extension" "linux_vm_file_command" {
  count                      = lower(var.os_type) == "linux" && try(var.script_file, null) != null && try(var.command, null) == null ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    script = base64encode(var.script_file)
  })

  tags               = var.tags
  virtual_machine_id = data.azurerm_virtual_machine.azure_vm.id

  lifecycle {
    ignore_changes = all
  }
}