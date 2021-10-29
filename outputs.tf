output "consul_client_sg_id" {
  description = "AWS security group ID to provide to Consul clients"
  value       = module.vm_servers.consul_clients_sg_id
}

output "consul_subnet_ids" {
  description = "AWS subnets ID to deploy Consul clients"
  value       = module.networking.consul_subnet_ids
}

output "kms_key_arn_s3_bucket" {
  description = "KMS Key ARN used for S3 bucket encryption. Any clients being provisioned will need to access this for the Consul Enterprise license"
  value       = module.object_storage.kms_key_arn
}


output "s3_bucket_consul_license_arn" {
  value = module.object_storage.s3_bucket_consul_license_arn
}

output "s3_bucket_consul_license" {
  value = module.object_storage.s3_bucket_consul_license
}

