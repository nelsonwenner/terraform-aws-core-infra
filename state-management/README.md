# Terraform Module – Remote State Management on AWS

This module provisions the necessary infrastructure to store the **Terraform remote state** in a **secure, versioned, and scalable** way on AWS using **Amazon S3**.

---

## Resources Created

- **S3 Bucket**
  - Stores the Terraform state file (`terraform.tfstate`).
  - **Versioning enabled**: complete history of state changes.
  - **At-rest encryption (AES-256)**: native S3 security.
  - **Public access blocking**: ensures the bucket is only accessed in a controlled manner.
  - **Object ownership control**: ensures the account that created the bucket retains ownership.
  - **TLS enforcement policy**: only allows HTTPS connections (forcing TLS usage).

---

## 📦 Prerequisites

- An AWS account with permissions to create resources.
- AWS CLI configured with valid credentials.
- Terraform **v1.0.0 or later**.

---

## Important

- This module must be **deployed before any others** that use the remote backend.
- The **region defaults to `us-east-1`**, as it provides global compatibility with other AWS services (such as IAM).
- Make sure **users or pipelines accessing this backend** have the proper permissions on both S3 and DynamoDB.

---

## 🚀 How to Use

### 1. Apply the Module

```bash
$ cd state-management
$ terraform init
$ terraform apply
```

This step will create the S3 bucket.

---

### 2. Configure the Remote Backend in Your Project

After the infrastructure is created, configure the `backend` block in your Terraform project as follows:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-bucket-name"
    key            = "path/to/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
```

---

## 📚 Additional Resources

- [Terraform S3 Backend – Official Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [AWS S3 – Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [Terraform State Locking](https://developer.hashicorp.com/terraform/language/state/locking)

---
