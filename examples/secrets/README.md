# EXAMPLE: Secrets Configuration on Consul Nodes

## About This Example

The Consul installation module requires TLS certificates on all the Consul nodes
in the cluster along with a [gossip encryption
key](https://www.consul.io/docs/security/encryption#gossip-encryption). If you
do not already have existing TLS certs and a gossip encryption key that you can
use for these requirements, you can use the example code in this directory to
create them and upload them to [AWS Secrets
Manager](https://aws.amazon.com/secrets-manager/).

Additionally, an ACL default server token will be created and stored in
the AWS Secrets Manager to be used with the Consul installation module.

## How to Use This Module

1. Ensure your AWS credentials are [configured
   correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
2. Configure required (and optional if desired) variables
3. Run `terraform init` and `terraform apply`

### Security Note:
- The [Terraform State](https://www.terraform.io/docs/language/state/index.html)
  produced by this code has sensitive data (cert private keys and gossip
  encryption key) stored in it. Please secure your Terraform state using the
  [recommendations listed
  here](https://www.terraform.io/docs/language/state/sensitive-data.html#recommendations).

## Required variables

* `aws_region` - AWS region to deploy resources into
* `resource_name_prefix` - string value to use as base for resource name

## Note

- Please note the following output produced by this Terraform as this
  information will be required input for the Consul installation module:
   - `secrets_manager_arn_acl_token_server`
   - `secrets_manager_arn_gossip`
   - `secrets_manager_arn_tls`

- The following output will be required as input if you are using the [example code](https://github.com/hashicorp/terraform-aws-consul-ent-starter/tree/main/examples/client) to spin up clients
   - `ca_cert`
