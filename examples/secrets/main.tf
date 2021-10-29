provider "aws" {
  region = var.aws_region
}

resource "aws_secretsmanager_secret" "tls" {
  name                    = "${var.resource_name_prefix}-tls-secret"
  description             = "contains TLS certs and private keys"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "tls" {
  secret_id     = aws_secretsmanager_secret.tls.id
  secret_string = local.secret
}


resource "aws_secretsmanager_secret" "gossip" {
  name                    = "${var.resource_name_prefix}-gossip-secret"
  description             = "contains gossip encryption key"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "gossip" {
  secret_id     = aws_secretsmanager_secret.gossip.id
  secret_string = random_id.gossip_encryption.b64_std
}

resource "aws_secretsmanager_secret" "acl_token_server" {
  name                    = "${var.resource_name_prefix}-acl-token-server"
  description             = "contains Consul server default ACL token"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "acl_token_server" {
  secret_id     = aws_secretsmanager_secret.acl_token_server.id
  secret_string = "default = \"${random_uuid.consul_server_default_token.result}\""
}

