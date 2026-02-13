Push-Location("$PsScriptRoot/AA-tf")

terraform destroy `
    -var entra_tenant_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id', 'User'))" `
    -var az_sub_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))" `
    -var workload_nickname="$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))" `
    -var current_gh_repo="$(gh repo view --json 'name' --jq '.name')" `
    -input=false `
    -auto-approve

Pop-Location