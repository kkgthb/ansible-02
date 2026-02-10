variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "azapi_resource_action_public_key" {
  type = string
}

variable "username" {
  type = string
}

variable "workload_nickname" {
  type = string
}

variable "nic_id" {
  type = string
}
