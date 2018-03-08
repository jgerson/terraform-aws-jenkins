variable "aws_region" {
  description = "AWS region"
}
variable "access_key" {
  description = "aws access_key"
}

variable "secret_key" {
  description = "aws secret_key"
}
variable "service_name" {
  description = "Unique name to use for DNS"
}

variable "aws_instance_ami" {
  description = "Amazon Machine Image ID"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  description = "AWS key pair name to install on the EC2 instance"
}

variable "owner" {
  description = "EC2 instance owner"
}

variable "ttl" {
  description = "EC2 instance TTL"
  default     = "168"
}
