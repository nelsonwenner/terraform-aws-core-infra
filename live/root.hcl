inputs = {
  region            = "us-east-1"
  project_name      = "zelda_iac"
  env               = "dev"
  domain_name       = "bigmemo.tech"
  host_headers      = "bigmemo"
  container_port    = "8080"

  tags = {
    environment     = "dev"
    project         = "zelda_iac"
    platform        = "aws"
    manager         = "terraform/terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region    = "us-east-1"
}
EOF
}
