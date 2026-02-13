variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    location = string
  })
}

variable "current_gh_repo" {
  type = string
}