include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  use_existing_zone = false
}

terraform {
  source = "../../../modules/route53"

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
