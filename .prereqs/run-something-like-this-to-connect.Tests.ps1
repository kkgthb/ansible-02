Describe "Validate Linux VM is up and loginnable" {
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

Describe "Validate Windows VM is up and loginnable" {
    # Once logged in, `(Get-ComputerInfo).OsManufacturer` should equal `Microsoft Corporation`
    It "should return correct remote kernel name" {
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
