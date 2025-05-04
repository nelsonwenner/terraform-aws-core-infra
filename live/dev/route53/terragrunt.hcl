include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  project_name  = include.root.locals.project_name
  env           = include.root.locals.env
  tags          = include.root.locals.tags
  domain_name   = include.root.locals.domain_name

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
