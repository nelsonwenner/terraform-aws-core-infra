output "repository_url" {
  description = "URI full of the ECR repository (without tag)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.this.arn
}

output "image_tag" {
  value = var.image_tag
}
