# AWS IAM Module

## Required variables

* `aws_bucket_consul_license_arn` - ARN of S3 bucket with Consul license
* `kms_key_arn` - KMS Key ARN used for S3 bucket encryption
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources
* `secrets_manager_arn_acl_token_server` - Secrets manager ARN where Consul server default ACL token is stored
* `secrets_manager_arn_gossip` - Secrets manager ARN where gossip encryption key is stored
* `secrets_manager_arn_tls` - Secrets manager ARN where TLS cert info is stored

## Example usage

```hcl
module "iam" {
  source = "./modules/iam"

  aws_bucket_consul_license_arn           = var.aws_bucket_consul_license_arn
  kms_key_arn                             = var.kms_key_arn
  resource_name_prefix                    = var.resource_name_prefix
  secrets_manager_arn_acl_token_server    = var.secrets_manager_arn_acl_token_server
  secrets_manager_arn_gossip              = var.secrets_manager_arn_gossip
  secrets_manager_arn_tls                 = var.secrets_manager_arn_tls
}
```
