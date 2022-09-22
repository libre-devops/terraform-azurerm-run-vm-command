variable "command" {
  description = "A string Command to be executed."
  default     = null
  type        = string
}

variable "location" {
  description = "Location of resources"
  type        = string
}

variable "os_type" {
  description = "Specifies the operating system type."
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group."
  type        = string
}

variable "script_file" {
  description = "A path to a local file for the script"
  type        = string
  default     = null
}

variable "script_uri" {
  description = "A URI for the script to be input raw"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the extension."
  default     = {}
  type        = map(any)
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}
