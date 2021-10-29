resource "aws_iam_instance_profile" "consul_server" {
  name_prefix = "${var.resource_name_prefix}-consul-server"
  role        = var.user_supplied_iam_role_name_server != null ? var.user_supplied_iam_role_name_server : aws_iam_role.instance_role_server[0].name
}

resource "aws_iam_role" "instance_role_server" {
  count              = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name_prefix        = "${var.resource_name_prefix}-consul-server"
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

resource "aws_iam_role_policy" "cloud_auto_join_server" {
  count  = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-server-auto-join"
  role   = aws_iam_role.instance_role_server[0].id
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

resource "aws_iam_role_policy" "kms_server" {
  count  = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-server-kms"
  role   = aws_iam_role.instance_role_server[0].id
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
      var.kms_key_arn,
    ]
  }
}

resource "aws_iam_role_policy" "session_manager_server" {
  count  = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-server-ssm"
  role   = aws_iam_role.instance_role_server[0].id
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

resource "aws_iam_role_policy" "secrets_manager_server" {
  count  = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-server-secrets"
  role   = aws_iam_role.instance_role_server[0].id
  policy = data.aws_iam_policy_document.secrets_manager_server.json
}

data "aws_iam_policy_document" "secrets_manager_server" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      var.secrets_manager_arn_acl_token_server,
      var.secrets_manager_arn_tls,
      var.secrets_manager_arn_gossip,
    ]
  }
}

resource "aws_iam_role_policy" "s3_bucket_consul_license_server" {
  count  = var.user_supplied_iam_role_name_server != null ? 0 : 1
  name   = "${var.resource_name_prefix}-consul-server-license-s3"
  role   = aws_iam_role.instance_role_server[0].id
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
