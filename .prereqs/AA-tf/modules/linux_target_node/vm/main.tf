resource "azurerm_linux_virtual_machine" "my_vm" {
  name                  = "${var.workload_nickname}LnxVm"
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [var.nic_id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = var.azapi_resource_action_public_key
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "my_entra_login_vm_extension" {
  virtual_machine_id   = azurerm_linux_virtual_machine.my_vm.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  name                 = "${var.workload_nickname}LnxAADSSHLoginForLinux"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
}

data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "myself_as_os_user" {
  role_definition_name = "Virtual Machine User Login"
  scope                = azurerm_linux_virtual_machine.my_vm.id
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "github_actions_secret" "gh_scrt_vm_username" {
  repository      = var.current_gh_repo
  secret_name     = "THE_LINUX_VM_USERNAME"
  plaintext_value = var.username
}