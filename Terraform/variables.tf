variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The name of the AWS key pair"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "cidr_blocks" {
  description = "List of allowed CIDR blocks"
  type        = list(string)
}

variable "ssh_key_path" {
  description = "ssh key path"
  type = string
}