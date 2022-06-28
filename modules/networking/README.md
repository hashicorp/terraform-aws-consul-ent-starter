# AWS Networking Module

## Required variables

* `vpc_id` - VPC ID where Consul will be deployed

## Example usage

```hcl
module "networking" {
  source = "./modules/networking"

  vpc_id              = var.vpc_id
}
```
