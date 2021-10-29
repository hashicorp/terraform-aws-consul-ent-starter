output "consul_license_name" {
  value = var.consul_license_name
}

output "kms_key_arn" {
  value = var.user_supplied_kms_key_arn != null ? var.user_supplied_kms_key_arn : aws_kms_key.s3_bucket_encryption[0].arn
}

output "s3_bucket_consul_license_arn" {
  value = aws_s3_bucket.consul_license_bucket.arn
}

output "s3_bucket_consul_license" {
  value = aws_s3_bucket.consul_license_bucket.id
}

