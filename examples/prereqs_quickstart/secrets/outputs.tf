output "ca_cert" {
  description = "Certificate Authority public cert"
  value       = tls_self_signed_cert.ca.cert_pem
}

output "secrets_manager_arn_acl_token_server" {
  description = "ARN of secrets_manager secret containing Consul server default ACL token"
  value       = aws_secretsmanager_secret.acl_token_server.arn
}

output "secrets_manager_arn_gossip" {
  description = "ARN of secrets_manager secret containing gossip encryption key"
  value       = aws_secretsmanager_secret.gossip.arn
}

output "secrets_manager_arn_tls" {
  description = "ARN of secrets_manager secret containing TLS cert data"
  value       = aws_secretsmanager_secret.tls.arn
}
