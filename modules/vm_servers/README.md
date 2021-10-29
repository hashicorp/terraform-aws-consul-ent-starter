# AWS VM_SERVERS Module

## Required variables

* `aws_iam_instance_profile` - IAM instance profile name to use for Consul instances
* `consul_subnets` - Private subnets where Consul will be deployed
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources
* `userdata_script` - Userdata script for EC2 instance. Must be base64-encoded.
* `vpc_id` - VPC ID where Consul will be deployed

## Example usage

```hcl
module "vm" {
  source = "./modules/vm_servers"

  aws_iam_instance_profile  = var.aws_iam_instance_profile
  consul_subnets            = var.consul_subnet_ids
  instance_type             = var.instance_type
  resource_name_prefix      = var.resource_name_prefix
  userdata_script           = var.userdata_script
  vpc_id                    = var.vpc_id
}
```
