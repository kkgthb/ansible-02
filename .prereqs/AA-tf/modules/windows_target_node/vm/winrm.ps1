param(
    [string]$fqdn
)

# Find or create certificate
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=$dnsName" }
if (-not $cert) {
    $cert = New-SelfSignedCertificate -DnsName $fqdn -CertStoreLocation 'Cert:\LocalMachine\My'
}
$thumb = $cert.Thumbprint

# Enable authenticated and encrypted WinRM
winrm quickconfig -q
winrm set winrm/config/service/auth '@{Basic=\"true\"}'
winrm set winrm/config/service '@{AllowUnencrypted=\"false\"}'

# Create HTTPS listener if not exists
$listener = winrm enumerate winrm/config/Listener | Select-String -Pattern "Transport = HTTPS"
if (-not $listener) {
    New-Item -Path 'WSMan:\LocalHost\Listener' -Transport 'HTTPS' -Address '*' -CertificateThumbPrint $thumb -Force
}

# Add firewall rule if not exists (note:  presumes OS is answering "netsh" in English)
$fwRule = netsh advfirewall firewall show rule name='WinRM HTTPS' | Select-String 'Rule Name'
if (-not $fwRule) {
    netsh advfirewall firewall add rule name='WinRM HTTPS' dir='in' action='allow' protocol='TCP' localport='5986'
}
