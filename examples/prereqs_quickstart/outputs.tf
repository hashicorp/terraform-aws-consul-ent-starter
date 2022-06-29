output "ca_cert" {
  description = "Certificate Authority public cert"
  value       = module.secret.ca_cert
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "secrets_manager_arn_acl_token_server" {
  description = "ARN of secrets_manager secret containing Consul server default ACL token"
  value       = module.secrets.secrets_manager_arn_acl_token_server
}

output "secrets_manager_arn_gossip" {
  description = "ARN of secrets_manager secret containing gossip encryption key"
  value       = module.secrets.secrets_manager_arn_gossip
}

output "secrets_manager_arn_tls" {
  description = "ARN of secrets_manager secret containing TLS certa data"
  value       = module.secrets.secrets_manager_arn_tls
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
