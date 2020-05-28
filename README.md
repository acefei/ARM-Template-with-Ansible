# Deploy ARM template with Ansible

## Installation
Find usage by running `make` command
```
$ make
dev-env              Enter dev container, default is in azure-cli container, shift by `make dev-env CONTAINER_NAME=ansible`
deploy               Deploy ARM template with Ansible
```

## Create Credentials for Ansible
Run the following within docker container
```
# login azure
az login

# list the Subscriptions associated with the account
az account list

# should you have more than one Subscription, you can specify the Subscription with the id field being the subscriptionId field referenced above.
az account set --subscription=<subscriptionId>

# create the Service Principal which will have permissions to manage resources 
az ad sp create-for-rbac -n CloudOps
```
After stepping through the above commands you will get the result:
```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "CloudOps",
  "name": "http://CloudOps",
  "password": ********************,
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

To pass service principal credentials via the environment, define the following variables:
```
export AZURE_SUBSCRIPTION_ID=<your-subscription_id>
export AZURE_CLIENT_ID=<security-principal-appid>
export AZURE_SECRET=<security-principal-password>
export AZURE_TENANT=<security-principal-tenant>
```

If you forget the password, reset the service principal credentials.
```
az ad sp credential reset --name <appId>
```

## Reference
- [Microsoft Azure Guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html)
- [Quickstart: Install Ansible on Linux virtual machines in Azure](https://docs.microsoft.com/en-us/azure/developer/ansible/install-on-linux-vm)
