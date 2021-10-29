# AWS Client Example

## About This Example

This example creates Consul client nodes with the appropriate permissions to
access the Consul Enterprise license and gossip encryption key provisioned in
the main module. Once the client nodes are provisioned, you must create an ACL
policy for them and attach the pre-generated token (similar to what is shown in
the main module
[README](https://github.com/hashicorp/terraform-aws-consul-ent-starter/blob/main/README.md)
for the servers) before they are able to join the Consul cluster using cloud
auto-join.

## How to Use This Module

1. Ensure your AWS credentials are [configured
   correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
2. Set the required (and optional as desired) variables in terraform.tfvars (the values below are example values. Be sure to change them):

```
aws_region = "us-east-1"
aws_bucket_consul_license_arn = "arn:aws:s3:::abc123"
aws_bucket_consul_license = "testbucket123"

ca_cert = <<-EOT
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOT

consul_subnets = [
  "subnet-123",
  "subnet-abc",
  "subnet-789",
]
consul_sg_id = "sg-abcxxxxx"
kms_key_arn_s3_bucket = "arn:aws:kms:us-east-1xxx"
resource_name_prefix = "this must be the same value provided to the main module for cloud auto-join to work properly"
secrets_manager_arn_gossip = "arn:aws::secretsmanager:abc123xyx"
vpc_id = "vpc-abc123xxx"
```

3. Run `terraform init` and `terraform apply`

## Required variables

* `aws_region` - AWS region where Consul is being deployed
* `aws_bucket_consul_license_arn` - ARN of S3 bucket with Consul license
* `aws_bucket_consul_license` - S3 bucket ID containing Consul license
* `ca_cert` - Certificate Authority public cert that was used to sign servers certs. This is required for auto_encrypt to work on the clients
* `consul_sg_id` - Security group ID that should be provided to Consul clients
* `consul_subnets` - Private subnets where Consul will be deployed
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources. For cloud auto-join purposes, this value must be the same value you provided when creating servers with the main Consul module.
* `secrets_manager_arn_gossip` - Secrets manager ARN where gossip encryption key is stored
* `vpc_id` - VPC ID where Consul will be deployed
