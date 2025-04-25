###############################
# main.tf
###############################
locals {
  # Turn the list into a predictable map for for_each
  cmd_map = {
    for idx, cmd in var.commands :
    coalesce(cmd.name, "run-command-${idx + 1}") => cmd
  }
}

#########################################
# Windows Run-Command (only if windows)
#########################################
resource "azurerm_virtual_machine_run_command" "windows" {
  for_each = lower(var.os_type) == "windows" ? local.cmd_map : {}

  name               = each.key
  location           = var.location
  virtual_machine_id = var.vm_id
  tags               = var.tags

  run_as_user     = try(each.value.run_as_user, null)
  run_as_password = try(each.value.run_as_password, null)

  ######################################
  # pick exactly one source
  ######################################
  dynamic "source" {
    for_each = try(each.value.inline, null) != null ? [1] : []
    content { script = each.value.inline }
  }
  dynamic "source" {
    for_each = try(each.value.script_file, null) != null ? [1] : []
    content { script = file(each.value.script_file) }
  }
  dynamic "source" {
    for_each = try(each.value.script_uri, null) != null ? [1] : []
    content { script_uri = each.value.script_uri }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        try(each.value.inline, null),
        try(each.value.script_file, null),
        try(each.value.script_uri, null)
      ])) == 1
      error_message = "Command '${each.key}' must set exactly ONE of inline, script_file, or script_uri."
    }
  }
}

#########################################
# Linux Run-Command (only if linux)
#########################################
resource "azurerm_virtual_machine_run_command" "linux" {
  for_each = lower(var.os_type) == "linux" ? local.cmd_map : {}

  name               = each.key
  location           = var.location
  virtual_machine_id = var.vm_id
  tags               = var.tags

  run_as_user     = try(each.value.run_as_user, null)
  run_as_password = try(each.value.run_as_password, null)

  # identical source logic -------------------------
  dynamic "source" {
    for_each = try(each.value.inline, null) != null ? [1] : []
    content { script = each.value.inline }
  }
  dynamic "source" {
    for_each = try(each.value.script_file, null) != null ? [1] : []
    content { script = file(each.value.script_file) }
  }
  dynamic "source" {
    for_each = try(each.value.script_uri, null) != null ? [1] : []
    content { script_uri = each.value.script_uri }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        try(each.value.inline, null),
        try(each.value.script_file, null),
        try(each.value.script_uri, null)
      ])) == 1
      error_message = "Command '${each.key}' must set exactly ONE of inline, script_file, or script_uri."
    }
  }
}
