$script_root_parent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetDirectoryName($PSScriptRoot))
$ansible_code_directory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($script_root_parent, 'ansible_demo_02'))
$ansible_configuration_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'ansible.cfg'))
$write_results_here = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'test-results', 'junit-results'))
$ansible_playbook_main_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'playbooks', 'main.yml'))
$ansible_requirements_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'meta', 'requirements.yml'))
$write_ssh_key_here = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'the_linux_vm_ssh_key.pem'))

Write-Host("Config file should be: '$ansible_configuration_file'")
Write-Host("Results should write to: '$ansible_configuration_file'")

# Specify which Ansible configuration file to use
[System.Environment]::SetEnvironmentVariable('ANSIBLE_CONFIG', $ansible_configuration_file, 'Process')

# Manually configure JUnit output path since Ansible configuration file not working
New-Item -Path $write_results_here -Type 'Directory' -Force | Out-Null
[System.Environment]::SetEnvironmentVariable('JUNIT_OUTPUT_DIR', $write_results_here, 'Process')

# Install a remote Ansible collection
Write-Host('Downloading and installing an Ansible collection:')
ansible-galaxy collection install -r $ansible_requirements_file --force # --force makes sure to always get the latest Git commits

# Manually configure to ensure SSH connections do not hang while waiting to trust a fingerprint
Write-Host('Setting fingerprint to auto-trust:')
[System.Environment]::SetEnvironmentVariable('ANSIBLE_HOST_KEY_CHECKING', 'False', 'Process')

# Tell Ansible in which file to find the SSH private key
Write-Host('Creating SSH key file:')
[System.Environment]::SetEnvironmentVariable('THE_LINUX_VM_SSH_KEY_PATH', $write_ssh_key_here, 'Process')
# Fill that file with the actual value of the SSH private key
Try {
    [System.IO.File]::WriteAllText( `
            $write_ssh_key_here, `
            [System.Environment]::GetEnvironmentVariable('THE_LINUX_VM_SSH_PRIVATE_KEY_VALUE')
    )
}
Catch {
    Write-Host "Failed to write SSH key file."
    Exit 1
}
# Chmod that file to something Ansible won't reject; by default it starts as 644.
chmod 600 $write_ssh_key_here

# Run Ansible
Write-Host('Running the main Ansible playbook file:')
ansible-playbook $ansible_playbook_main_file -v

# Delete the file that contained the SSH key
Write-Host('Deleting SSH key file:')
Remove-Item -Path $write_ssh_key_here -Force

Write-Host('Done.')