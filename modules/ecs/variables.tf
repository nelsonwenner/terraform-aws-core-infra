variable "env" {}

variable "region" {}

variable "vpc_id" {}

variable "alb_sg_id" {}

variable "project_name" {}

variable "tags" { type = map(string) }

variable "cluster_name" {}

variable "private_subnet_ids" { type = list(string) }

variable "container_port" { type = number }

variable "image_uri" {}

variable "target_group_arn" {}

variable "desired_count" {
  type    = number
  default = 1
}

