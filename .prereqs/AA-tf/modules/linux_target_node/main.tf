module "ssh_keys_demo" {
  source = "./ssh"
  resource_group = {
    id       = var.resource_group.id
    location = var.resource_group.location
  }
}

module "network_demo" {
  source = "./network"
  resource_group = {
    id       = var.resource_group.id
    name     = var.resource_group.name
    location = var.resource_group.location
  }
  workload_nickname = var.workload_nickname
}

module "vm_demo" {
  source = "./vm"
  resource_group = {
    id       = var.resource_group.id
    name     = var.resource_group.name
    location = var.resource_group.location
  }
  nic_id                           = module.network_demo.nic_id
  username                         = "foobar"
  azapi_resource_action_public_key = module.ssh_keys_demo.key_data
  workload_nickname                = var.workload_nickname
}
