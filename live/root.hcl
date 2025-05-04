remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    region           = "us-east-1"
    bucket           = "terraform-iac-topgear"
    key              = "${path_relative_to_include()}/terraform.tfstate"
    encrypt          = true
  }
}

locals {
  region            = "us-east-1"
  project_name      = "topgear"
  env               = "dev"
  domain_name       = "bigmemo.tech"
  host_headers      = "bigmemo"
  container_port    = 8080

  image_tag      = "latest"

  tags = {
    environment     = "dev"
    project         = "topgear"
    platform        = "aws"
    manager         = "terraform/terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
  }
}

provider "aws" {
  region    = "us-east-1"
}
EOF
}
