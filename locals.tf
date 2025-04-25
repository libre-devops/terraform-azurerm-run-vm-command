############################################
# helper: unified map of run-command objects
############################################
locals {
  # windows or linux map will be empty – merge keeps the non-empty one
  run_cmds = merge(
    { for n, rc in azurerm_virtual_machine_run_command.windows : n => rc },
    { for n, rc in azurerm_virtual_machine_run_command.linux : n => rc }
  )
}
