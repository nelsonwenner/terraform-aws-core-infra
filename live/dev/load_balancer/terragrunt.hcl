include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" { config_path = "../vpc" }

dependency "route53" { config_path = "../route53" }

inputs = {
  project_name   = include.root.locals.project_name
  env            = include.root.locals.env
  tags           = include.root.locals.tags
  domain_name   = include.root.locals.domain_name
  container_port = include.root.locals.container_port

  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  route53_zone_id   = dependency.route53.outputs.route53_zone_id
  certificate_arn   = dependency.route53.outputs.acm_arn
  host_headers      = "topgear"
}

terraform {
  source = "../../../modules/load_balancer"

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
