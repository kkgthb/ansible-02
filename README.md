# Ansible demo 2

This repository contains a small demonstration of Ansible code.

The [.cicd_pipeline_helpers/i_only_run_on_posix_not_windows.ps1](.cicd_pipeline_helpers/i_only_run_on_posix_not_windows.ps1) PowerShell script runs one Ansible **play**, which:

1. Installs an external Ansible **collection** named `katiekodes.ansible_demo_first`, which I published in my `ansible-01` repo, just to show off how importing works.
2. Runs [ansible_demo_02/playbooks/main.yml](ansible_demo_02/playbooks/main.yml) Ansible **playbook** against the following three Ansible inventory **hosts**:
    * The machine on which the PowerShell script itself is running _(local)_.
    * A remote Linux Azure VM.
        * _(Presuming it's been provisioned first with appropriate `.prereqs/*.ps1` scripts.)_
    * A remote Windows Azure VM.
        * _(Presuming it's been provisioned first with appropriate `.prereqs/*.ps1` scripts.)_
3. The `main.yml` Ansible **playbook** performs one simple, cross-platform filesystem operation _(running the `katiekodes.ansible_demo_first.helloworld` Ansible **role** imported from my `ansible-01` repo)_ against each targeted inventory host.
4. The `katiekodes.ansible_demo_first.helloworld` Ansible **role** simply:
    * Creates a directory on the targeted host's filesystem.
    * Verifies the directory exists on the target.
    * Writes a text file into that directory.
    * Verifies the file exists on the target.
5. Writes JUnit output, summarizing the Ansible **play**'s results, into a `ansible_demo_02/test-results/` folder of the machine on which the PowerShell script itself is running.
