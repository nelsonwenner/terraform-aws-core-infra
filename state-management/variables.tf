variable "region" {
  type        = string
  description = "AWS region for the S3 bucket"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name for tagging"
  default     = "infra"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to store Terraform state"
  default     = "manager-terraform-state-bucket"
}
