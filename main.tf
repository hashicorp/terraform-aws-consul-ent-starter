data "aws_region" "current" {}

module "iam" {
  source = "./modules/iam"

  aws_bucket_consul_license_arn        = module.object_storage.s3_bucket_consul_license_arn
  kms_key_arn                          = module.object_storage.kms_key_arn
  resource_name_prefix                 = var.resource_name_prefix
  secrets_manager_arn_acl_token_server = var.secrets_manager_arn_acl_token_server
  secrets_manager_arn_gossip           = var.secrets_manager_arn_gossip
  secrets_manager_arn_tls              = var.secrets_manager_arn_tls
  user_supplied_iam_role_name_server   = var.user_supplied_iam_role_name_server
}

module "networking" {
  source = "./modules/networking"

  vpc_id = var.vpc_id
}

module "object_storage" {
  source = "./modules/object_storage"

  common_tags               = var.common_tags
  user_supplied_kms_key_arn = var.user_supplied_kms_key_arn
  kms_key_deletion_window   = var.kms_key_deletion_window
  resource_name_prefix      = var.resource_name_prefix
  consul_license_filepath   = var.consul_license_filepath
  consul_license_name       = var.consul_license_name
}

module "user_data" {
  source = "./modules/user_data"

  aws_bucket_consul_license            = module.object_storage.s3_bucket_consul_license
  aws_region                           = data.aws_region.current.name
  consul_license_name                  = module.object_storage.consul_license_name
  consul_version                       = var.consul_version
  node_count_servers                   = var.node_count_servers
  resource_name_prefix                 = var.resource_name_prefix
  secrets_manager_arn_acl_token_server = var.secrets_manager_arn_acl_token_server
  secrets_manager_arn_gossip           = var.secrets_manager_arn_gossip
  secrets_manager_arn_tls              = var.secrets_manager_arn_tls
  user_supplied_userdata_path_server   = var.user_supplied_userdata_path_server
}

module "vm_servers" {
  source = "./modules/vm_servers"

  allowed_inbound_cidrs_ssh = var.allowed_inbound_cidrs_ssh
  aws_iam_instance_profile  = module.iam.aws_iam_instance_profile_server
  common_tags               = var.common_tags
  instance_type             = var.instance_type
  key_name                  = var.key_name
  server_count              = var.node_count_servers
  resource_name_prefix      = var.resource_name_prefix
  userdata_script           = module.user_data.consul_userdata_server_base64_encoded
  user_supplied_ami_id      = var.user_supplied_ami_id
  consul_subnets            = var.private_subnet_ids
  vpc_id                    = module.networking.vpc_id
}
