variable "env" {}

variable "use_existing_zone" {
  description = "Whether to use an existing hosted zone or create a new one"
  type        = bool
}

variable "domain_name" {}

variable "project_name" {}

variable "tags" {
  type    = map(string)
}
