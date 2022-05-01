
##Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "private_key_path" {}
variable "public_key_path" {}

variable "key_name" {
  default = "PriyadarsheeKeys"
}


variable "instance_name" {
  description = "The Name tag to set for the EC2 Instance."
  default     = "httpsshserver"
}

variable "ssh_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  default     = 22
}

variable "http_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  default     = 80
}

variable "ssh_user" {
  description = "SSH user name to use for remote exec connections,"
  default     = "ec2-user"
}

variable "ami_name" {
  default = "ami-0cb0e70f44e1a4bb5"
}


