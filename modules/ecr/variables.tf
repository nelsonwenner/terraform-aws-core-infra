variable "env" {}

variable "project_name" {}

variable "tags" {
  type = map(string)
}

variable "image_tag" {
  type    = string
}
