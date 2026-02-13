output "winrm_kv_id" {
  value = azurerm_key_vault.winrm_kv.id
}

output "winrm_cert_id" {
  value = azurerm_key_vault_certificate.winrm_cert.id
}

output "winrm_cert_url" {
  value = azurerm_key_vault_certificate.winrm_cert.secret_id
}