resource "azurerm_virtual_machine_extension" "windows_vm_inline_command" {
  count                      = lower(var.os_type) == "windows" && try(var.script_uri, null) == null && try(var.script_file, null) == null && try(var.command, null) != null ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = tolist([var.command])
  })

  tags               = var.tags
  virtual_machine_id = data.azurerm_virtual_machine.azure_vm.id

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_virtual_machine_extension" "windows_vm_uri_command" {
  count                      = lower(var.os_type) == "windows" && try(var.script_uri, null) == null && try(var.script_file, null) != null && try(var.command, null) == null ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    fileUris = compact(tolist([var.script_uri]))
  })

  tags               = var.tags
  virtual_machine_id = data.azurerm_virtual_machine.azure_vm.id

  lifecycle {
    ignore_changes = all
  }
}


resource "azurerm_virtual_machine_extension" "windows_vm_file_command" {
  count                      = lower(var.os_type) == "windows" && try(var.script_uri, null) == null && try(var.script_file, null) != null && try(var.command, null) == null ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = compact(tolist([var.script_file]))
  })

  tags               = var.tags
  virtual_machine_id = data.azurerm_virtual_machine.azure_vm.id

  lifecycle {
    ignore_changes = all
  }
}
