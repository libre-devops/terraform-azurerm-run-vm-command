variable "commands" {
  description = "One-or-many commands to run on the VM"
  type = list(object({
    name            = optional(string) # extension name; auto when null
    inline          = optional(string)
    script_file     = optional(string)
    script_uri      = optional(string)
    run_as_user     = optional(string)
    run_as_password = optional(string)
  }))
}

variable "location" {
  description = "Azure region (same as the VM)"
  type        = string
}

variable "os_type" {
  description = "Operating system of the VM: windows | linux"
  type        = string
  validation {
    condition     = contains(["windows", "linux"], lower(var.os_type))
    error_message = "os_type must be \"windows\" or \"linux\"."
  }
  default = "windows"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to every Run-Command resource"
}

variable "vm_id" {
  description = "ID of the VM the commands should run on"
  type        = string
}
