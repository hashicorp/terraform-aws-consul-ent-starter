variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "consul_license_filepath" {
  type        = string
  description = "Absolute filepath to location of Consul license file"
}

variable "consul_license_name" {
  type        = string
  description = "Filename for Consul license file"
}

variable "kms_key_deletion_window" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource (must be between 7 and 30 days)."
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix used for tagging and naming AWS resources"
}

variable "user_supplied_kms_key_arn" {
  type        = string
  description = "(Optional) User-provided KMS key ARN. This is used for S3 bucket encryption."
}

