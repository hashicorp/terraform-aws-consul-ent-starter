variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags which specify the subnets to deploy Consul into"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Consul will be deployed"
}

