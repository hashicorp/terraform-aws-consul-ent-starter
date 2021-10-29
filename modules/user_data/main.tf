locals {
  consul_user_data_server = templatefile(
    var.user_supplied_userdata_path_server != null ? var.user_supplied_userdata_path_server : "${path.module}/templates/install_consul_server.sh.tpl",
    {
      consul_license_name           = var.consul_license_name
      consul_version                = var.consul_version
      instance_count                = var.node_count_servers
      name                          = var.resource_name_prefix
      region                        = var.aws_region
      s3_bucket_consul_license      = var.aws_bucket_consul_license
      secrets_manager_arn_acl_token = var.secrets_manager_arn_acl_token_server
      secrets_manager_arn_gossip    = var.secrets_manager_arn_gossip
      secrets_manager_arn_tls       = var.secrets_manager_arn_tls
    }
  )
}

