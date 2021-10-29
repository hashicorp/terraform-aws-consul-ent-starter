# AWS Object Storage Module

## Required variables

* `consul_license_filepath` - Absolute filepath to location of Consul license file
* `consul_license_name` - Filename for Consul license file
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources

## Example usage

```hcl
module "object_storage" {
  source = "./modules/object_storage"

  consul_license_filepath = var.consul_license_filepath
  consul_license_name     = var.consul_license_name
  resource_name_prefix    = var.resource_name_prefix
}
```
