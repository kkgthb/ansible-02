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
