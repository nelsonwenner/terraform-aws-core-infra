
variable "subnet_id" {
  type = string
}

variable "ec2_private_or_public" {
  type    = string
}

variable "associate_public_ip_address" {
  type    = bool
}

variable "key_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_ssh_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
