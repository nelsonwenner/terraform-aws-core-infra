include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  vpc_cidr_block              = "10.0.0.0/16"
  public_subnet1_cidr_block   = "10.0.1.0/24"
  public_subnet2_cidr_block   = "10.0.2.0/24"
  private_subnet1_cidr_block  = "10.0.3.0/24"
  private_subnet2_cidr_block  = "10.0.4.0/24"

  availability_zone1 = "us-east-1a"
  availability_zone2 = "us-east-1b"
}

terraform {
  source = "../../../modules/vpc"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]
  }
}
