resource "random_uuid" "consul_client_default_token" {}

resource "aws_secretsmanager_secret" "acl_token_client" {
  name                    = "${var.resource_name_prefix}-acl-token-client"
  description             = "contains Consul client default ACL token"
  kms_key_id              = var.kms_key_arn_secrets_manager
  recovery_window_in_days = var.recovery_window
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "acl_token_client" {
  secret_id     = aws_secretsmanager_secret.acl_token_client.id
  secret_string = "default = \"${random_uuid.consul_client_default_token.result}\""
}

resource "aws_iam_instance_profile" "consul_client" {
  name_prefix = "${var.resource_name_prefix}-consul-client"
  role        = var.user_supplied_iam_role_name_client != null ? var.user_supplied_iam_role_name_client : aws_iam_role.instance_role_client[0].name
}

resource "aws_iam_role" "instance_role_client" {
  count              = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name_prefix        = "${var.resource_name_prefix}-consul-client"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloud_auto_join_client" {
  count  = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-client-auto-join"
  role   = aws_iam_role.instance_role_client[0].id
  policy = data.aws_iam_policy_document.cloud_auto_join.json
}

data "aws_iam_policy_document" "cloud_auto_join" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "kms_client" {
  count  = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-client-kms"
  role   = aws_iam_role.instance_role_client[0].id
  policy = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [
      var.kms_key_arn_s3_bucket,
    ]
  }
}

resource "aws_iam_role_policy" "session_manager_client" {
  count  = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-client-ssm"
  role   = aws_iam_role.instance_role_client[0].id
  policy = data.aws_iam_policy_document.session_manager.json
}

data "aws_iam_policy_document" "session_manager" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "secrets_manager_client" {
  count  = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-client-secrets"
  role   = aws_iam_role.instance_role_client[0].id
  policy = data.aws_iam_policy_document.secrets_manager_client.json
}

data "aws_iam_policy_document" "secrets_manager_client" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.acl_token_client.arn,
      var.secrets_manager_arn_gossip,
    ]
  }
}

resource "aws_iam_role_policy" "s3_bucket_consul_license_client" {
  count  = var.user_supplied_iam_role_name_client != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-client-license-s3"
  role   = aws_iam_role.instance_role_client[0].id
  policy = data.aws_iam_policy_document.s3_bucket_consul_license.json
}

data "aws_iam_policy_document" "s3_bucket_consul_license" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      var.aws_bucket_consul_license_arn,
      "${var.aws_bucket_consul_license_arn}/*",
    ]
  }
}

data "aws_ami" "ubuntu" {
  count       = var.user_supplied_ami_id != null ? 0 : 1
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  consul_user_data_client = templatefile(
    var.user_supplied_userdata_path_client != null ? var.user_supplied_userdata_path_client : "${path.module}/templates/install_consul_client.sh.tpl",
    {
      ca_cert                       = var.ca_cert
      consul_license_name           = var.consul_license_name
      consul_version                = var.consul_version
      name                          = var.resource_name_prefix
      region                        = var.aws_region
      secrets_manager_arn_acl_token = aws_secretsmanager_secret.acl_token_client.arn
      s3_bucket_consul_license      = var.aws_bucket_consul_license
      secrets_manager_arn_gossip    = var.secrets_manager_arn_gossip
    }
  )
}

resource "aws_launch_template" "consul_clients" {
  name          = "${var.resource_name_prefix}-consul-clients"
  image_id      = var.user_supplied_ami_id != null ? var.user_supplied_ami_id : data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null
  user_data     = base64encode(local.consul_user_data_client)
  vpc_security_group_ids = [
    var.consul_sg_id,
  ]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = "gp3"
      volume_size           = 100
      throughput            = 150
      iops                  = 3000
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.consul_client.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "consul_clients" {
  name                = "${var.resource_name_prefix}-consul-clients"
  min_size            = var.client_count
  max_size            = var.client_count
  desired_capacity    = var.client_count
  vpc_zone_identifier = var.consul_subnets

  launch_template {
    id      = aws_launch_template.consul_clients.id
    version = "$Latest"
  }

  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.resource_name_prefix}-consul-client"
        propagate_at_launch = true
      }
    ],
    [
      {
        key                 = "${var.resource_name_prefix}-consul"
        value               = "cluster"
        propagate_at_launch = true
      }
    ],
    [
      for k, v in var.common_tags : {
        key                 = k
        value               = v
        propagate_at_launch = true
      }
    ]
  )
}
