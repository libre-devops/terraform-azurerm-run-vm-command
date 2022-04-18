variable "rg_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "Location of resources"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "os_type" {
  description = "Specifies the operating system type."
  type        = string
}

variable "command" {
  default     = ""
  description = "A string Command to be executed."
  type        = string
}

variable "timestamp" {
  default     = ""
  description = "Intended to trigger re-execution of the script when changed."

}

variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to the extension."
  type        = map(any)
}
