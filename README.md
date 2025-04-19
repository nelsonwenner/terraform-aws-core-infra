# AWS Infrastructure with Terraform

## Overview

This repository provides an Infrastructure as Code (IaC) setup using **Terraform** to provision and manage a basic cloud architecture on AWS for hosting applications.

## Environments

The project supports multiple isolated environments through shared reusable modules. Currently, only the following is implemented:

- **dev** – Development environment

## Project Structure

```bash
├── environments/            # Environment-specific configuration
│   └── dev/                 # Development environment setup
├── modules/                 # Reusable Terraform modules
│   ├── ec2/                 # EC2 instance provisioning (to be defined)
│   ├── vpc/                 # VPC and subnet configuration (to be defined)
│   ├── networking/          # Networking configuration (e.g., VPC endpoints)
├── state-management/        # Remote state backend configuration (S3 + locking)
```

## Prerequisites

Ensure the following tools are installed and configured:

- [Terraform ≥ 1.0.0](https://www.terraform.io/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) with valid credentials
- Basic knowledge of Terraform, AWS IAM, and infrastructure components

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/nelsonwenner/terraform-aws-core-infra.git
cd terraform-infra-basic
```

### 2. Configure AWS credentials

```bash
aws configure
```

### 3. Set up remote state backend

Follow the instructions in the [`state-management`](./state-management/README.md) directory to configure secure, versioned, and scalable **Terraform remote state** storage using **Amazon S3**.

---

## Deployment Workflow

### Deploy to a specific environment (e.g., `dev`):

```bash
cd environments/dev
terraform init           # Initialize provider plugins and backend
terraform plan           # Preview planned changes
terraform apply          # Apply changes to AWS
```

---

## Maintenance

### Updating infrastructure

To apply updates after modifying any configuration:

1. Modify the necessary `.tf` files  
2. Run `terraform plan` to inspect the execution plan  
3. Run `terraform apply` to apply the changes

### Destroying infrastructure

To remove all resources from a specific environment (⚠️ irreversible):

```bash
terraform destroy
```

---
