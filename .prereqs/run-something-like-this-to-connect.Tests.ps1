Describe "Validate Linux VM is up and loginnable as me" {
    # Once logged in, `uname --kernel-name` should equal `Linux`
    It "should return correct remote kernel name" {
        $remote_kernel_name = az ssh vm `
            --subscription "$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))" `
            --resource-group "$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))-rg-demo" `
            --vm-name "$("$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))")LnxVm" `
            -- "uname --kernel-name"
        $remote_kernel_name | Should -Not -BeNullOrEmpty
        $remote_kernel_name | Should -Be 'Linux'
    }
}

Describe "Validate Linux VM is up and loginnable over SSH via admin username and password" {
    # Once logged in, `uname --kernel-name` should equal `Linux`
    BeforeAll {
        $tfstate_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'AA-tf', 'terraform.tfstate'))
        $lnx_vm_fqdn = (jq -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_LINUX_VM_FQDN") | .attributes.plaintext_value' $tfstate_file)
        $lnx_vm_admin_username = (jq -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_LINUX_VM_USERNAME") | .attributes.plaintext_value' $tfstate_file)
        $lnx_vm_admin_ssh_private_key_value = (
            jq `
                -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_LINUX_VM_SSH_PRIVATE_KEY_VALUE") | .attributes.plaintext_value' `
                --binary `
                $tfstate_file
        )
        $temp_private_key_path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), '.ssh', 'temp_ssh_key.pem'))
        $lnx_vm_admin_ssh_private_key_value | Set-Content -Path $temp_private_key_path
        $ssh_command = "ssh -i `"$temp_private_key_path`" -o StrictHostKeyChecking=no $lnx_vm_admin_username@$lnx_vm_fqdn uname --kernel-name"
    }
    It "should return correct remote kernel name" {
        $remote_kernel_name = Invoke-Expression $ssh_command
        $remote_kernel_name | Should -Not -BeNullOrEmpty
        $remote_kernel_name | Should -Be 'Linux'
    }
    AfterAll {
        Remove-Item -Path $temp_private_key_path -Force
        $ssh_command = $null
        $lnx_vm_fqdn = $null
        $lnx_vm_admin_username = $null
        $lnx_vm_admin_ssh_private_key_value = $null
        $tfstate_file = $null
    }
}

Describe "Validate Windows VM is up and loginnable as me" {
    # Once logged in, `(Get-ComputerInfo).OsManufacturer` should equal `Microsoft Corporation`
    It "should return correct remote OS manufacturer" {
        $remote_kernel_os_manufacturer = ( `
                az vm run-command invoke `
                --subscription "$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))" `
                --resource-group "$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))-rg-demo" `
                --name "$("$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))")WinVm" `
                --command-id 'RunPowerShellScript' `
                --scripts @("Get-ComputerInfo | Select-Object -Property 'OsManufacturer' -ExpandProperty 'OsManufacturer'") `
        )
        $remote_kernel_os_manufacturer_vm_weirdness_postprocessed = $remote_kernel_os_manufacturer `
        | ConvertFrom-Json `
        | Select-Object -Property 'value' -ExpandProperty 'value' `
        | Where-Object { $_.code -eq 'ComponentStatus/StdOut/succeeded' } `
        | Select-Object -First 1 `
        | Select-Object -Property 'message' -ExpandProperty 'message'
        $remote_kernel_os_manufacturer_vm_weirdness_postprocessed | Should -Not -BeNullOrEmpty
        $remote_kernel_os_manufacturer_vm_weirdness_postprocessed | Should -Be 'Microsoft Corporation'
    }
}

Describe "Validate Windows VM is up and loginnable over WinRM via admin username and password" {
    # Once logged in, `(Get-ComputerInfo).OsManufacturer` should equal `Microsoft Corporation`
    BeforeAll {
        $sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
        $tfstate_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'AA-tf', 'terraform.tfstate'))
        $win_vm_fqdn = (jq -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_WINDOWS_VM_FQDN") | .attributes.plaintext_value' $tfstate_file)
        $win_vm_admin_username = (jq -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_WINDOWS_VM_USERNAME") | .attributes.plaintext_value' $tfstate_file)
        $win_vm_admin_password = (jq -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="THE_WINDOWS_VM_PASSWORD") | .attributes.plaintext_value' $tfstate_file)
        $win_vm_admin_password_ss = ConvertTo-SecureString $win_vm_admin_password -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($win_vm_admin_username, $win_vm_admin_password_ss)
        $win_vm_admin_username = $null
        $win_vm_admin_password = $null
        $win_vm_admin_password_ss = $null
        $tfstate_file = $null
    }
    It "should return correct remote OS manufacturer" {
        $remote_kernel_os_manufacturer = Invoke-Command `
            -ComputerName $win_vm_fqdn `
            -Credential $cred `
            -UseSSL `
            -Port 5986 `
            -SessionOption $sessionOption `
            -ScriptBlock { Get-ComputerInfo | Select-Object -ExpandProperty 'OsManufacturer' }
        $remote_kernel_os_manufacturer | Should -Not -BeNullOrEmpty
        $remote_kernel_os_manufacturer | Should -Be 'Microsoft Corporation'
    }
}
