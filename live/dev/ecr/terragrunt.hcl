include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  project_name  = include.root.locals.project_name
  env           = include.root.locals.env
  tags          = include.root.locals.tags
  image_tag     = include.root.locals.image_tag
}

terraform {
  source = "../../../modules/ecr"

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
