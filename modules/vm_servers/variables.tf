variable "allowed_inbound_cidrs_ssh" {
  type        = list(string)
  description = "List of CIDR blocks to give SSH access to Consul nodes"
  default     = null
}

variable "aws_iam_instance_profile" {
  type        = string
  description = "IAM instance profile name to use for Consul servers"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "consul_subnets" {
  type        = list(string)
  description = "Private subnets where Consul will be deployed"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "key pair to use for SSH access to instance"
  default     = null
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix used for tagging and naming AWS resources"
}

variable "server_count" {
  type        = number
  description = "Number of Consul servers to deploy in ASG"
  default     = 5
}

variable "userdata_script" {
  type        = string
  description = "Userdata script for EC2 instance"
}

variable "user_supplied_ami_id" {
  type        = string
  description = "AMI ID to use with Consul servers"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Consul will be deployed"
}
