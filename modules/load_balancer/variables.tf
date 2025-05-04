variable "env" {}

variable "project_name" {}

variable "tags" { type = map(string) }

variable "vpc_id" {}

variable "route53_zone_id" {}

variable "public_subnet_ids" { type = list(string) }

variable "certificate_arn" {}

variable "domain_name" {}

variable "host_headers" {}

variable "container_port" {
  description = "The port on which the container is listening"
  type        = number
}