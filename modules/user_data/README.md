# AWS User Data Module

## Required variables

* `aws_bucket_consul_license` - S3 bucket ID containing Consul license
* `aws_region` - AWS region where Consul is being deployed
* `consul_license_name` - Name of Consul license file
* `consul_version` - Consul version
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources
* `secrets_manager_arn_acl_token_server` - Secrets manager ARN where Consul server default ACL token is stored
* `secrets_manager_arn_gossip` - Secrets manager ARN where gossip encryption key is stored
* `secrets_manager_arn_tls` - Secrets manager ARN where TLS cert info is stored

## Example usage

```hcl
module "user_data" {
  source = "./modules/user_data"

  aws_bucket_consul_license                   = var.aws_bucket_consul_license
  aws_region                                  = var.aws_region
  consul_license_name                         = var.consul_license_name
  consul_version                              = var.consul_version
  resource_name_prefix                        = var.resource_name_prefix
  secrets_manager_arn_acl_token_server        = var.secrets_manager_arn_acl_token_server
  secrets_manager_arn_gossip                  = var.secrets_manager_arn_gossip
  secrets_manager_arn_tls                     = var.secrets_manager_arn_tls
}
```
