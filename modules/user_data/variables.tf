variable "aws_bucket_consul_license" {
  type        = string
  description = "S3 bucket ID containing Consul license"
}

variable "aws_region" {
  type        = string
  description = "AWS region where Consul is being deployed"
}

variable "consul_license_name" {
  type        = string
  description = "Name of Consul license file"
}

variable "consul_version" {
  type        = string
  description = "Consul version"
}

variable "node_count_servers" {
  type        = number
  description = "Number of Consul server nodes to deploy"
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix used for tagging and naming AWS resources"
}

variable "secrets_manager_arn_gossip" {
  type        = string
  description = "Secrets manager ARN where gossip encryption key is stored"
}

variable "secrets_manager_arn_tls" {
  type        = string
  description = "Secrets manager ARN where TLS cert info is stored"
}

variable "secrets_manager_arn_acl_token_server" {
  type        = string
  description = "Secrets manager ARN where Consul server default ACL token is stored"
}

variable "user_supplied_userdata_path_client" {
  type        = string
  description = "File path to custom userdata script being supplied by the user for Consul client configuration"
  default     = null
}

variable "user_supplied_userdata_path_server" {
  type        = string
  description = "File path to custom userdata script being supplied by the user for Consul server configuration"
  default     = null
}
