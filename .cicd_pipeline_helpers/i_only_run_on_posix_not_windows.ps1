$script_root_parent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetDirectoryName($PSScriptRoot))
$ansible_code_directory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($script_root_parent, 'ansible_demo_02'))
$ansible_configuration_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'ansible.cfg'))
$write_results_here = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'test-results', 'junit-results'))
$ansible_playbook_main_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'playbooks', 'main.yml'))
$ansible_requirements_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ansible_code_directory, 'meta', 'requirements.yml'))

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

# Run Ansible
Write-Host('Running the main Ansible playbook file:')
ansible-playbook $ansible_playbook_main_file -v

Write-Host('Done.')
