# TopGear Emulator on AWS ECS/Fargate

![Architecture Diagram](https://github.com/user-attachments/assets/6a9803f3-0022-43a0-8139-d5a8fe3c1d49)

## Description

**What problem does this implementation solve?**  
This repo provides a simple, AWS infrastructure for hosting a TopGear game emulator as a Docker image on ECS/Fargate. It includes networking (VPC, public/private subnets, NAT gateways, route tables), compute (ECS cluster & service), load balancing (ALB + HTTPS), DNS (Route 53 + ACM), storage (ECR), logging (CloudWatch), and IAM roles — all managed via Terraform + Terragrunt.

**What has been done?**  
- **Infrastructure as Code** with Terraform modules and Terragrunt live configurations  
- **Remote state** stored in S3 with versioning, encryption & locking  
- **Networking**: VPC, public & private subnets (2 AZs), Internet Gateway, one NAT Gateway per AZ, route tables, VPC endpoints  
- **ECR**: Repositories for `ecr-dev-topgear-fargate` 
- **ECS/Fargate**: Cluster, Task Definitions & Services for web containers  
- **Load Balancer**: Application Load Balancer (HTTP→HTTPS redirect + HTTPS listener)  
- **DNS & TLS**: Route 53 A-Alias, ACM wildcard certificate with DNS validation  
- **CI/CD**: Instructions to build the TopGear emulator Docker image, push to your ECR, and deploy via ECS  

---

## Prerequisites

- **Terraform** ≥ 1.11
- **Terragrunt** ≥ 0.77
- **AWS CLI** ≥ 2.0 (configured with proper IAM permissions)
- **Docker** (to build the emulator image)
- Basic familiarity with AWS IAM, VPC, ECS & ECR  

---

## Project Structure

```bash
.
├── modules/                    # Reusable Terraform modules
│   ├── state_management/       # S3 backend & locking
│   ├── vpc/                    # VPC, subnets, IGW, NAT, routes, VPC endpoints, security groups
│   ├── ecr/                    # ECR repositories, lifecycle & policies
│   ├── load_balance/           # ALB, target groups, listeners, Route53
│   ├── ecs/                    # ECS cluster, IAM roles, task & service
│   └── route53/                # ACM + Route 53 validation & records
│
├── live/                       # Terragrunt “live” configurations
│   ├── global/
│   │   └── state_management/   # S3 bucket for remote state
│   └── dev/                    # Development environment
│       ├── vpc/
│       ├── ecr/
│       ├── load_balance/
│       ├── ecs/
│       └── route53/
│
└── architecture_diagram.png    # High-level infra diagram
```

---

## Setup & Deployment

### 1. Bootstrap remote state (once)

```bash
$ cd live/global/state_management
$ terragrunt apply
```

This will create the S3 bucket (with versioning + encryption) to hold all Terraform state files.

### 2. Deploy the `dev` environment

```bash
$ cd live/dev
$ terragrunt run-all apply
```

This will provision **everything** under your AWS account in the `us-east-1` region.

### 3. Destroy all resources

To tear down your `dev` environment:

```bash
$ cd live/dev
$ terragrunt run-all destroy
```

---

## Building & Pushing the TopGear Docker Image

1. **Clone the emulator repo**  
   ```bash
   $ git clone https://github.com/nelsonwenner/docker-emulator-topgear.git
   $ cd docker-emulator-topgear
   ```

2. **Build the Docker image**  
   ```bash
   $ docker build -t topgear-emulator:latest .
   ```

3. **Authenticate to your ECR**  
   ```bash
   $ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   ```

4. **Tag & push**  
   ```bash
   ECR_URI=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/ecr-dev-topgear-fargate
   docker tag topgear-emulator:latest $ECR_URI:latest
   docker push $ECR_URI:latest
   ```

5. **Force new deployment**  
   - In your ECS Service `ecs_cluster-dev-topgear-fargate` Run a new deploy.
     - The new task definition will launch Fargate tasks running your TopGear emulator.

6. Go to the URL https://topgear.<YOUR_DOMAIN>

---

## AWS Resources Used

| Category            | Resources                                                                                   |
|---------------------|---------------------------------------------------------------------------------------------|
| **Networking**      | VPC, Public & Private Subnets (2 AZs), Internet Gateway, NAT Gateways, Route Tables, VPC Endpoints |
| **Compute**         | ECS Cluster (Fargate), Task Definitions, Services                                           |
| **Storage**         | ECR Repositories (lifecycle & scan on push)                                                 |
| **Load Balancing**  | Application Load Balancer, Target Groups, HTTP→HTTPS Redirect & HTTPS Listener              |
| **DNS & TLS**       | Route 53 Hosted Zone & A-Alias Record, ACM Wildcard Certificate with DNS Validation         |
| **IAM & Security**  | IAM Roles & Policies (ECS Task Execution), Security Groups                                  |
| **Logging**         | CloudWatch Log Group(s) for ECS                                                             |
| **State Backend**   | S3 Bucket (versioning, encryption), DynamoDB Table (locking via Terragrunt/state)           |

---

## About Terraform & Terragrunt

- **Terraform** is a declarative, provider-agnostic IaC tool. We define **what** the infrastructure should look like, and Terraform handles the API calls.  
- **Terragrunt** is a thin wrapper that allows DRY patterns, remote-state bootstrapping, and orchestration across multiple modules/environments (`run-all`, `plan-all`, etc.).  

---

## Further Reading

- [Terraform Documentation](https://www.terraform.io/docs)  
- [Terragrunt GitHub](https://github.com/gruntwork-io/terragrunt)  
- [AWS ECS & Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)  
- [AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)  

---

*Happy gaming on Fargate!* 🎮
