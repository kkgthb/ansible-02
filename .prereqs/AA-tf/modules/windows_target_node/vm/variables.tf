variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    name     = string
    location = string
  })
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

variable "fqdn" {
  type = string
}

variable "current_gh_repo" {
  type = string
}