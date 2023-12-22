# Jenkins Server Terraform Configuration

## Overview
This Terraform configuration is designed for setting up a Jenkins server in Azure. It manages resources necessary for a robust Jenkins deployment, ensuring an organized and scalable infrastructure.

## Configuration Files

### `jenkins_server.tf`
- Sets up the Jenkins-specific Azure resources.
- Creates a dedicated resource group for Jenkins.
- Manages public IPs for Jenkins server access.
- Manages initial chef run to install and implement Jenkins software. 

### `provider.tf`
- Configures the Terraform backend for Azure.
- Specifies required Azure provider settings, including dynamic subscription IDs.

### `variables.tf`
- Defines essential variables for the deployment.
- Includes settings for the Azure region and details of the Linux image for the Jenkins server.

## Prerequisites
- Azure account with required permissions.
- Terraform installed and properly configured.
- Chef Server up and running with cookbooks available. 
    - cb_dvo_resolveDNS, 
    - cb_dvo_chefClient, 
    - cb_dvo_selinux, 
    - cb_dvo_adjoin, 
    - cb_dvo_sshd, 
    - cb_dvo_authorization, 
    - cb_dvo_prtg, 
    - cb_dvo_docker, 
    - cb_dvo_localAccounts, 
    - cb_dvo_jenkins"

## Usage
1. **Initialization**: Begin by initializing Terraform with `terraform init`.
2. **Configuration**: Update `variables.tf` as per your Azure environment.
3. **Execution**: Deploy the infrastructure using `terraform apply`.

## Security and Maintenance
- Securely handle your Azure credentials and Terraform state files.
- Regularly update the Terraform scripts to align with Azure and Jenkins updates.

For detailed configuration and customization, refer to the contents within each Terraform file.

---

Note: This README is a draft and should be further refined for detailed instructions and best practices specific to your infrastructure and organizational needs.