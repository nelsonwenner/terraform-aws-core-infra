module "vpc" {
  source      = "../../modules/vpc"
  environment = var.environment
}

module "networking" {
  source              = "../../modules/networking"
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "us-east-1a"
  environment         = var.environment
}

module "ec2_public" {
  source            = "../../modules/ec2"
  subnet_id  = module.networking.public_subnet_id
  associate_public_ip_address = true
  key_name          = "key-pair-ec2-public"
  security_group_id = module.networking.security_group_id
  ec2_private_or_public  = "public"
  environment       = var.environment
}

module "ec2_private" {
  source            = "../../modules/ec2"
  subnet_id  = module.networking.private_subnet_id
  associate_public_ip_address = false
  key_name          = "key-pair-ec2-private"
  security_group_id = module.networking.security_group_id
  ec2_private_or_public  = "private"
  environment       = var.environment
}
