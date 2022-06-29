# EXAMPLE: Prerequisite Configuration (VPC and Secrets)

## About This Example

The quickstart directory provides example code that will create one Amazon VPC
along with AWS Secrets Manager secrets containing TLS certs, a gossip encryption key,
and an ACL default server token. 

The Amazon VPC will have the following:
- Three public subnets
- Three NAT gateways (one in each public subnet)
- Three private subnets (the nodes from the EKS managed node group will be
  deployed here).

## How to Use This Module

1. Ensure your AWS credentials are [configured
   correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
2. Configure required (and optional if desired) variables
3. Run `terraform init` and `terraform apply`

## Required variables

* `resource_name_prefix` - string value to use as base for resource names

## Note

- The default AWS region is `us-east-1` (as specified by the `aws_region`
  variable). You may change this if you wish to deploy Consul elsewhere, but
  please be sure to change the value for the `azs` variable as well and specify
  the appropriate availability zones for your new region.

### Security Note:
- The [Terraform State](https://www.terraform.io/docs/language/state/index.html)
  produced by this code has sensitive data (cert private keys) stored in it.
  Please secure your Terraform state using the [recommendations listed
  here](https://www.terraform.io/docs/language/state/sensitive-data.html#recommendations).

## Note:

- The following output is only required if you are using the [example code](https://github.com/hashicorp/terraform-aws-consul-ent-starter/tree/main/examples/client) to spin up clients
   - `ca_cert`
