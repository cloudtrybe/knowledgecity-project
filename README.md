# **Terraform KnowledgeCity Infrastructure**

This project sets up the infrastructure for the KnowledgeCity ecosystem on AWS using Terraform. It includes the following key components:

1. **VPC and Networking**: Custom VPC, public and private subnets, and Internet Gateway.
2. **ClickHouse Database**: EC2 instances running ClickHouse with security groups.
3. **Scalable Modular Design**: Built for reusability and easy customization.

---

## **Table of Contents**
1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Usage](#usage)
   - [Initialization](#initialization)
   - [Planning](#planning)
   - [Deployment](#deployment)
   - [Cleanup](#cleanup)
4. [Customizations](#customizations)
5. [Best Practices](#best-practices)

---

## **Prerequisites**

Ensure you have the following installed on your local machine:
- [Terraform](https://www.terraform.io/downloads) (v1.5.0 or higher)
- AWS CLI configured with the appropriate credentials
- Access to an AWS account with permissions for EC2, VPC, S3, and CloudFront

Additionally, you'll need:
- An AWS Key Pair for SSH access
- An existing ACM certificate ARN (for secure CloudFront distribution)
- Public and private subnet CIDR ranges

---

## **Project Structure**
```plaintext
knowledgecity-project/
├── main.tf               # Root Terraform module
├── variables.tf          # Global variables
├── outputs.tf            # Global outputs
├── providers.tf          # AWS provider configuration
├── backend.tf            # Remote backend to  store the Terraform state file (terraform.tfstate)
├── modules/              # Reusable modules
│   ├── cloudfront_s3/    # SPA hosting and CloudFront
│   ├── ecs_fargate/      # ECS cluster and Fargate services
│   ├── rds/              # RDS module for MySQL
│   ├── ec2_clickhouse/   # ClickHouse on EC2
│   ├── networking/       # Networking (VPC, subnets, Route 53, etc.)
└── environment/          # Environment-specific configurations
    ├── dev/
    │   └── terraform.tfvars  # Dev environment variables
    ├── staging/
    │   └── terraform.tfvars  # Staging environment variables
    └── prod/
        └── terraform.tfvars  # Production environment variables
```


## **Usage**
1. #### **Initialization**

Run the following command to initialize the project and download necessary plugins and modules:
```bash
terraform init
```
2. #### **Planning**

To see what changes Terraform will make, execute the plan command:
```bash
terraform plan -var-file=environment/<env>/terraform.tfvars
```
Replace <env> with the target environment, such as dev, staging, or prod.

3. #### **Deployment**

Apply the changes to create the infrastructure:
```bash
terraform apply -var-file=environment/<env>/terraform.tfvars
```
Type **yes** when prompted to confirm the deployment.


4. #### **Cleanup**

To delete all resources created by Terraform, run:
```bash
terraform apply -var-file=environment/<env>/terraform.tfvars
```

## **Customizations**
# Environment Variables

Each environment (e.g., dev, staging, prod) has its own configuration file in the environment/ folder. Update the terraform.tfvars file to modify variables like:

- CIDR ranges for subnets
- Number of ClickHouse instances
- AWS Key Pair name

## **Modules**

Modules are reusable components:

- ec2_clickhouse: Customize the instance type, AMI ID, and allowed inbound IPs in variables.tf.
- vpc: Modify the VPC and subnet configuration as needed.

## **Best Practices**

- Use Terraform state backends like AWS S3 with DynamoDB locking for remote state management in a team setting.
- Enable version control for the project to track changes.
- Always test infrastructure changes in a staging environment before applying them to production.
- Apply tagging consistently to all resources for better organization and cost management.