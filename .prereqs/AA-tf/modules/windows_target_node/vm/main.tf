resource "random_password" "admin_pw" {
  length  = 32
  special = true
}

resource "azurerm_windows_virtual_machine" "my_vm" {
  name                  = "${var.workload_nickname}WinVm"
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [var.nic_id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myWinOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username
  admin_password = random_password.admin_pw.result

  identity {
    type = "SystemAssigned"
  }

  # Note:  This has to be commented out on the first pass of provisioning this resource.
  # secret {
  #   key_vault_id = var.winrm_kv_id
  #   certificate {
  #     store = "My" # The Windows personal certificate store
  #     url   = var.winrm_cert_url
  #   }
  # }

  # Note:  This has to be commented out on the first pass of provisioning this resource.
  # No nevermind, dangit, that doesn't work because changing forces a new resource to be created.
  # winrm_listener {
  #   protocol        = "Https"
  #   certificate_url = var.winrm_cert_url
  # }
}
# data "azurerm_virtual_machine" "my_vm_data" {
#   name                = "${var.workload_nickname}WinVm"
#   resource_group_name = var.resource_group.name
# }
# resource "azurerm_role_assignment" "vm_can_read_cert" {
#   # We use a "data" resource to force-fail if we forgot to do a 1st round of provisioning the VM w/ parts commented out.
#   principal_id         = data.azurerm_virtual_machine.my_vm_data.identity[0].principal_id
#   scope                = var.winrm_cert_id
#   role_definition_name = "Key Vault Certificate User"
# }

resource "azurerm_virtual_machine_extension" "my_entra_login_vm_extension" {
  virtual_machine_id   = azurerm_windows_virtual_machine.my_vm.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  name                 = "${var.workload_nickname}AADLoginForWindows"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
}

# resource "azurerm_virtual_machine_extension" "my_winrm_https_vm_extension" {
#   virtual_machine_id   = azurerm_windows_virtual_machine.my_vm.id
#   publisher            = "Microsoft.Compute"
#   name                 = "${var.workload_nickname}EnableWinRM"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"
#   settings             = <<SETTINGS
#     {
#       "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"\
#         $cert = New-SelfSignedCertificate -DnsName '${var.workload_nickname}WinVm' -CertStoreLocation 'Cert:\\LocalMachine\\My'; \
#         $thumb = $cert.Thumbprint; \
#         winrm quickconfig -q; \
#         winrm set winrm/config/service/auth '@{Basic=\"true\"}'; \
#         winrm set winrm/config/service '@{AllowUnencrypted=\"false\"}'; \
#         New-Item -Path WSMan:\\LocalHost\\Listener -Transport HTTPS -Address * -CertificateThumbPrint $thumb -Force; \
#         netsh advfirewall firewall add rule name='WinRM HTTPS' dir=in action=allow protocol=TCP localport=5986\""
#     }
# SETTINGS
# }

data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "myself_as_os_user" {
  role_definition_name = "Virtual Machine User Login"
  scope                = azurerm_windows_virtual_machine.my_vm.id
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "github_actions_secret" "gh_scrt_vm_username" {
  repository      = var.current_gh_repo
  secret_name     = "THE_WINDOWS_VM_USERNAME"
  plaintext_value = var.username
}

resource "github_actions_secret" "gh_scrt_vm_winrm_pw" {
  repository      = var.current_gh_repo
  secret_name     = "THE_WINDOWS_VM_PASSWORD"
  plaintext_value = random_password.admin_pw.result
  # Note:  I'm not sure if plaintext_value would be secure enough for production, but 
  # this is just throwaway infrastructure I keep destroying between runs anyway, and my 
  # Terraform state file is secured.
}
