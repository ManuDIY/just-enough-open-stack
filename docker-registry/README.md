# Docker Registry configuration and population

# Generating CA

The Docker runtime requires TLS certificates for all Docker Registry instances to ensure transportation integrity and security. It's typically impractical to get one of the Certificate Authorities that is "browser trusted" to sign an internal registry. If your organization has an Internal CA that is already installed on your workstation/desktop systems then you can skip most of this section and just deploy the public CA certs and running the registry with an internally signed cert.

If you don't already have CA infrastructure, you'll need to build one for your registry. This document will show how to do this using the [CFSSL](https://cfssl.org) toolkit. You will need the `cfssl` and `cfssljson` tools to complete this.

## Generate CFSSL CA JSON

Create a file called `ca.json` and include the following contents:

```
{
  "CN": "Internal Docker CA",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Docker",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
```

You can modify this as you see fit. Do leave the algo as RSA, since ECDSA keys have lower support across older distributions for now. The key size can be increased, but should not be decreased below 2048.

## Generate CFSSL CA Key and Certificate

Now, run the following command:

`cfssl gencert -initca ca.json | cfssljson -bare ca`

This will create a `ca.pem` file, which is your PUBLIC Certificate file, and a `ca-key.pem` file which is your PRIVATE key file. Keep the private key file private, but the public certificate needs to be deployed to every machine that will communicate with the docker registry.

## Generate CFSSL key/cert pair for the Docker Registry

Now you will need to generate the JSON and cert/key pair for the registry server. Start by creating a `registry.json` file with the following contents:

```
{
  "CN": "docker-registry.example.com",
  "hosts": [
    "127.0.0.1",
    "10.0.0.10",
    "docker-registry.example.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
```

You will need to make adjustments on this file. First you will need to replace the hostname `docker-registry.example.com` with the desired hostname of your docker registry host. Note that this host name does not need to correctly resolve in DNS from all hosts, since we'll be accessing by IP address directly instead. This leads to the second issue, the IP address `10.0.0.20` needs to be changed to the IP address the docker clients will be using to contact the docker registry. Leave the `127.0.0.1` address, as that will be used occasionally and it's better to have than not have.

Now you will need to generate the key/cert files with the following command:

`cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -profile=server registry.json | cfssljson -bare registry`

Like the CA command above, this will create a `registry.pem` PUBLIC certificate file and `registry-key.pem` PRIVATE key file. Both files as well as the CA certificate will need to be copied to the docker registry host.

# Deploying Docker Registry

Next, we need to deploy the Docker Registry. If the designated host has Internet access, then you can simply run the following command:

`docker run --name registry registry:2`

That will download and run the registry in a non-persistant state. You can then `docker stop registry` after it succeeds in downloading and running.

If you need to pull the image on another machine, run `docker pull registry:2` on a machine with Internet access, then `docker export registry:2 > registry_2.tar`, copy that tar file to the machine that will run the registry, then on that machine run `docker import registry_2.tar`. Now you can use the `docker run` command.

# Populating Docker Registry

Next, you will need to setup the persistent storage for your registry and then start it. Start by running `sudo mkdir -p /srv/docker-registry` and then `chown` that folder to your user. Next run `mkdir /srv/docker-registry/certs /srv/docker-registry/storage`. Now you need to put the `registry.pem` and `registry-key.pem` files in `/srv/docker-registry/certs`.

Next you need to get the registry storage tarball from the following URL:  https://s3.us-east-2.amazonaws.com/edolnx-public/docker-registry-2017-v0_1_1.tar.gz (note: this file is around 8GB in size and will require around 40G when extracted)

Now you can extract the tarball using `tar zxC /srv/docker-registry -f docker-registry-2017-v0_1_1.tar.gz`

Once this is done, you can simply start the docker registry and tell docker to keep it running using this command:

`docker run -d --restart=always --name registry -v /srv/docker-registry/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry-key.pem -p 443:443 -v /srv/docker-registry/storage:/var/lib/registry registry:2`

This will start the docker registry on tcp/443 and will keep it running. There is no auth on the private registry, so any requests will be honored. Best to keep the registry behind firewalls. Also note that you cannot run other services on port tcp/443, but you can map to a different port (but this will require a lot of changes to playbooks, etc. later).

# Deploying CA

Now that the registry is running, you need to place the CA cert for the registry on every machine. You can use the `docker-prerequistes.yml` playbook in this directory. The playbook will install docker and store the `ca.pem` file in the correct directory based on the IP address or hostname used to access the docker registry as defined in the inventory file via the `repo_host` variable.
