# HSM Ingress Controller example

> This repo is still a work in progress, it is developed in tandem with the documentation on [our website](https://ingress-demo.strid.tech).

Example code to deploy your own AKS cluster with [HSM Ingress Controller](https://ingress.strid.tech) extension.
Includes Bicep code to deploy everything you need for a basic cluster, and a simple Kubernetes deployment to showcase TLS offload.

> Note: You should read and understand the Bicep. The deployment might not be suitable for production workloads.

There is a demo deployment at https://ingress-demo.strid.tech

[<img width=270 height=90 src="./media/MS_Azure_Marketplace.png">](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/stridtech.ingress-nginx-hsm)

## Deploy Bicep

Create a SSH key unless you already have one:

```bash
# Create an SSH key pair using Azure CLI
az sshkey create --name "mySSHKey" --resource-group "myResourceGroup"

# Create an SSH key pair using ssh-keygen
ssh-keygen -t rsa -b 4096
```

Deploy the infrastructure providing your public key:

```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters linuxAdminUsername=<linux-admin-username> sshRSAPublicKey='<ssh-key>'
```

### Interested in using the HSM ingress?

Visit https://ingress.strid.tech or contact us at [info@strid.tech](mailto:info@strid.tech) if you want to learn more.

[<img width=270 height=90 src="./media/MS_Azure_Marketplace.png">](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/stridtech.ingress-nginx-hsm)
