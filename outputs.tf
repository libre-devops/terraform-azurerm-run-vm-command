output "vm_run_command_ids" {
  description = "Resource IDs of all azurerm_virtual_machine_run_command objects"
  value       = { for name, rc in local.run_cmds : name => rc.id }
}

output "vm_run_command_instance_view" {
  description = "Instance-view information for each run-command"
  value       = { for name, rc in local.run_cmds : name => rc.instance_view }
}

output "vm_run_command_locations" {
  description = "Azure region where each run-command resource is created"
  value       = { for name, rc in local.run_cmds : name => rc.location }
}

output "vm_run_command_names" {
  description = "Name property of each run-command resource"
  value       = { for name, rc in local.run_cmds : name => rc.name }
}

output "vm_run_command_script_uris" {
  description = "script_uri values for commands defined via script_uri"
  value = {
    for name, rc in local.run_cmds :
    name => try(rc.source[0].script_uri, null)
  }
}

output "vm_run_command_scripts" {
  description = "Inline script content for commands defined via inline or script_file"
  value = {
    for name, rc in local.run_cmds :
    name => try(rc.source[0].script, null)
  }
}
