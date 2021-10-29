resource "aws_kms_key" "s3_bucket_encryption" {
  count                   = var.user_supplied_kms_key_arn != null ? 0 : 1
  deletion_window_in_days = var.kms_key_deletion_window
  description             = "AWS KMS Customer-managed key used for S3 bucket encryption"
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = merge(
    { Name = "${var.resource_name_prefix}-kms" },
    var.common_tags,
  )
}

resource "aws_s3_bucket" "consul_license_bucket" {
  bucket_prefix = "${var.resource_name_prefix}-consul-license"
  acl           = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.user_supplied_kms_key_arn != null ? var.user_supplied_kms_key_arn : aws_kms_key.s3_bucket_encryption[0].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = true

  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "consul_license_bucket" {
  bucket = aws_s3_bucket.consul_license_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_object" "consul_license" {
  bucket = aws_s3_bucket.consul_license_bucket.id
  key    = var.consul_license_name
  source = var.consul_license_filepath

  tags = var.common_tags
}
