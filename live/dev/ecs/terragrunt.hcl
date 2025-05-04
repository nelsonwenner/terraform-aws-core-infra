include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" { config_path = "../vpc" }

dependency "load_balancer" { config_path = "../load_balancer" }

dependency "ecr" { config_path = "../ecr" }

inputs = {
  project_name   = include.root.locals.project_name
  env            = include.root.locals.env
  region         = include.root.locals.region
  tags           = include.root.locals.tags
  container_port = include.root.locals.container_port

  cluster_name       = "ecs_cluster-dev-topgear-fargate"
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids

  image_uri          = "${dependency.ecr.outputs.repository_url}:${dependency.ecr.outputs.image_tag}"

  alb_sg_id          = dependency.load_balancer.outputs.alb_sg_id
  target_group_arn   = dependency.load_balancer.outputs.target_group_arn
  desired_count      = 2
}

terraform {
  source = "../../../modules/ecs"

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
