# Project Description
This project provides Terraform templates for deploying infrastructure on Microsoft Azure and a Packer template for creating custom VM images. The infrastructure includes virtual networks, subnets, network security groups, public IP addresses, load balancers, and virtual machine scale sets.
## Dependencies
1. Create an Azure Account
2. Install the Azure command line interface
3. Install Packer
4. Install Terraform
## Getting Started
To use the templates in this project, follow these steps:

1. Clone this repository to your local machine.
2. Ensure you have the necessary credentials and permissions to access your Azure subscription.
3. Update the `vars.tf` file with your desired configuration parameters.
4. Export below environment variables by using service principal credentials
```
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
```
4. Run Packer to build a custom VM image using the provided packer.json file.
5. Run Terraform to deploy the infrastructure using the provided Terraform configuration files.
## Running Packer Templates
To run the Packer template:

1. Ensure you have Packer installed on your machine.
2. Navigate to the directory containing the packer.json file.
3. Update the values in the packer.json file with your Azure credentials and desired configuration.
4. Run the following command to build the VM image:
```
packer build packer.json
``` 
## Running Terraform Templates
To run the Terraform templates:

1. Ensure you have Terraform installed on your machine.
2. Navigate to the directory containing the Terraform configuration files (main.tf, vars.tf, etc.).
3. Update the values in the vars.tf file with your desired configuration.
4. Initialize the Terraform environment by running:
```
terraform init
```
1. Run the following command to validate the configuration:
```
terraform validate
```
1. If the validation is successful, apply the changes by running:
```
terraform apply
```
## Customization
To customize the templates for your use:

1. Update the `vars.tf` file with your desired values for variables such as resource group name, location, VM size, etc.
2. Modify the Packer template (`packer.json`) to adjust the image configuration, such as OS type, publisher, offer, SKU, etc.
3. Add or remove resources in the Terraform configuration files (`main.tf`, `network.tf`, etc.) based on your requirements.