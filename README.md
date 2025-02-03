# HSM Ingress Controller example

Example code to deploy your own AKS cluster with [HSM Ingress Controller](https://ingress.strid.tech) extension.
Includes Bicep code to deploy everything you need for a basic cluster, and a simple Kubernetes deployment to showcase TLS offload.

> Note: You should read and understand the Bicep. The deployment might not be suitable for production workloads.

There is a demo deployment at https://ingress-demo.strid.tech

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
