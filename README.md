# Three-Tier Architecture Deployment for WordPress with Terraform and Ansible

## Overview
This repository provides a solution to deploy WordPress on AWS using a three-tier architecture model. The infrastructure is provisioned using Terraform, while Ansible is used for the configuration and setup of WordPress on EC2 instances.

## Architecture Components
The key AWS resources provisioned in this setup include:

* **VPC** with isolated subnets for security and scaling
  * **2x Availability Zones (AZs)** for redundancy
  * **3x Subnets**: Public, Private, and Database
* **1x Internet Gateway** for external access
* **2x NAT Gateways** for internet connectivity in private subnets
* **Auto Scaling Group** with EC2 instances (t2.micro) to scale as needed
  * Desired Instances: 2
  * Maximum Instances: 3
* **Application Load Balancer (ALB)** for distributing traffic to EC2 instances
* **RDS Database (MySQL)** for storing WordPress data

## Architecture Diagram
![AWS Architecture](image.png)

## Prerequisites
Ensure you have the following before proceeding:
* AWS Account with the necessary permissions (AdministratorAccess or equivalent)
* Installed Terraform CLI
* Installed Ansible for server configuration

## Getting Started
The project involves two main parts: provisioning infrastructure using Terraform and deploying WordPress using Ansible.

### Clone the Repository
```bash
git clone https://github.com/sagar-uprety/aws-three-tier-architecture-automation
cd aws-three-tier-architecture-automation
```

## Part 1: Provision AWS Infrastructure with Terraform
To set up the infrastructure, follow these steps:

1. Navigate to the Terraform directory:
   ```bash
   cd infra-terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the infrastructure changes:
   ```bash
   terraform plan --var-file="dev.tfvars"
   ```

4. Apply the configuration to provision the resources:
   ```bash
   terraform apply --var-file="dev.tfvars"
   ```

5. **Cleanup**: If needed, destroy the infrastructure:
   ```bash
   terraform destroy --var-file="dev.tfvars"
   ```

## Project Structure

* **`main.tf`**: Defines the core infrastructure for VPC, RDS, and S3
* **`alb.tf`**: Configuration for the Application Load Balancer
* **`asg.tf`**: Auto Scaling Group configuration for managing EC2 instances
* **`variables.tf`**: Input variables for parameterization and sensitive data
* **`provider.tf`**: Specifies the AWS provider
* **`output.tf`**: Defines outputs such as Auto Scaling Group ID and RDS endpoint
* **`dev.tfvars`**: Variables specific to the dev environment
* **`.gitignore`**: Lists files to exclude from version control

## Part 2: Configure and Deploy WordPress with Ansible
Once the infrastructure is ready, follow these steps to install and configure WordPress using Ansible:

1. Navigate to the Ansible directory:
   ```bash
   cd ansible
   ```

2. Create a `group_vars/all.yml` file to define variables for MySQL and WordPress. Do not commit this file to source control. Check out [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html) if you want to explore other options.
   ```yaml
   mysql_db_name: "your-wordpress-db-name"
   mysql_user: "your-mysql-username"
   mysql_password: "your-mysql-password"
   mysql_host_address_ip: "your-rds-endpoint"
   ```

3. Configure Ansible's dynamic inventory to use AWS Systems Manager (SSM) for instance access:
   * In `wordpress.aws_ec2.yml`, set the `autoscaling_group_id` to the value from `terraform output`

4. Verify the dynamic inventory setup:
   ```bash
   ansible-inventory -i wordpress.aws_ec2.yml --list
   ```

5. Run the Ansible playbook to install and configure WordPress:
   ```bash
   ansible-playbook -i wordpress.aws_ec2.yml wordpress_playbook.yml
   ```

## Contributing
Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature-branch
   ```
3. Commit your changes and push the branch:
   ```bash
   git push origin feature-branch
   ```
4. Open a pull request to merge your changes

## License
This project is licensed under the [MIT License](https://opensource.org/license/mit/).