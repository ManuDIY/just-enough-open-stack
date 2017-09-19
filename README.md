# just-enough-open-stack
Install a _real_ OpenStack onto hardware with the Kolla containerized OpenStack model

# Goals

 * Self-contained provisioning node (no need for Internet access once provisioning node is created)
 * Use Digital Rebar Provision to do inital CentOS install and management network configuration
 * Target systems will be bootstrapped to use the provisioning node for all repos
 * Target systems will have all necessary dependencies to run docker-ce and ansible

# Provisioning Node

The provisioning node can be built as a VM image for use in existing virtual environment or on a bare metal node. Either method will require that the buidling of the provisioning need Internet access (via an http(s) proxy will work, everything is done over http(s) to create local mirrors). The provisioning node will need to be on the same Layer 2 network segment as the primary NICs (which have PXE support) of all the target nodes. The provisioning node will run a TFTP and DHCP server for the process of deploying the node. Those services can be disabled after nodes are deployed. The provisioning node will require at least 80GB of storage and must run on an x86_64 node (in order to run some Docker images). CPU requirements are trivial (minimum one virtual core), and RAM needs to be 1GB or greater.