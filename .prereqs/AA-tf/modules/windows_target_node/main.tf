module "network_demo" {
  source = "./network"
  resource_group = {
    id       = var.resource_group.id
    name     = var.resource_group.name
    location = var.resource_group.location
  }
  workload_nickname = var.workload_nickname
  current_gh_repo   = var.current_gh_repo
}

module "vm_demo" {
  source = "./vm"
  resource_group = {
    id       = var.resource_group.id
    name     = var.resource_group.name
    location = var.resource_group.location
  }
  nic_id            = module.network_demo.nic_id
  fqdn              = module.network_demo.fqdn
  username          = "barfoo"
  workload_nickname = var.workload_nickname
  current_gh_repo   = var.current_gh_repo
}
