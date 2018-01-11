## YUM Mirroring tool

This script will mirror the YUM/DNF repos needed for a behind-the-firewall deployment. It currently supports the following operating system distributions:

* CentOS 7
* Fedora 26

Others can be added. Mirroring both distributions will consume approximately 100G of drive space. By default, the mirrors are stored in the default httpd web root directory.

# Prerequisites
The tool assumes you have a httpd package installed, and that it will be able to write to `/var/www/html/mirrors` - this can be adjusted in the script. The tool also assumes you are running on a CentOS or Fedora based distribution and have the `yum-utils` and `createrepo` packages installed. Finally, the tool assumes you have the contents of the `rpm-gpg` directory installed in `/etc/pki/rpm-gpg` so that GPG verfication can be done.

# Usage
Calling the script without command line arguments will mirror everything. You can specify individual components (see the script itself for a list of those) or groups on the command line. The supported groups:

* common - Components which can be used by any distribution (less than 1G)
* c7 - CentOS 7 and it's related components (approx 30G)
* f26 - Fedora 26 and it's related components (approx 70G)
