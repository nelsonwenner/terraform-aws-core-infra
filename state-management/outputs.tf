output "bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of the S3 bucket created to store Terraform state"
}

output "bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "ARN of the S3 bucket created to store Terraform state"
}

output "aws_region" {
  description = "AWS region where the state resources were created"
  value       = var.region
}
