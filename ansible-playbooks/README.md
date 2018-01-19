# Ansible playbooks

## Fixes for Fedora based hosts

Fedora installs (at least 26 and up) do not include the components required for being able to manage the installs using Ansible. When performing an install, the "Ansible Host" option must be checked in the software configuration for Ansible to be available. However, if your running ansible from a Python 2.7 based system, you may still run into errors when attempting to write files. Specifically you may get an error that `libselinux-python` is not installed.

Running the `fedora-fix.yml` playbook will install the correct packages even if dnf package manager mirror configuration on the host is not yet properly setup. The playbook only needs to be run once per install, and is idempotent so it will not hurt to run again. The playbook is not automatically included in the `repos-updates.yml` playbook because due to Python module requirements it still would not be available for Ansible to use before the end of the playbook run. So, it's a separate playbook.

The playbook will simply install the `libselinux-python` package from the Fedora base OS mirror located on the `repo_host` node. It will take no action on hosts that are not Fedora based.

## Repos and Updates

The `repos-updates.yml` playbook will install all required keys and repositories needed for deploying Kubernetes and/or OpenStack Kolla on all hosts in the inventory. It will then flush all the package manager caches, install all updates, and then verify that the mirrors and keys are still in place. It uses two include files: `centos-mirrors.yml` and `f26-mirrors.yml` which should not be run independently.

# Example Inventory

An example inventory file is provided in `inventory.yml`. The target nodes should be categorized into the groups `openstack` and `k8s`. The `repo_host` variable is used by several playbooks to provide the IP where the local Docker Registry and YUM Mirrors are. Use of hostnames are supported, but not recommended.
