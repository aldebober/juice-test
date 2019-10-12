variable "terraform_bucket" {}
variable "terraform_key" {}

variable "region" {}
variable "profile" {}

variable "server_instance_type" {}
variable "ssh_private_key" {}

variable "segment" {}
variable "project" {}

variable "service_name" {
  type        = "string"
  description = "The name of the service these resources belong to."
}

