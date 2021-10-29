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

resource "aws_security_group" "consul_servers" {
  name   = "${var.resource_name_prefix}-consul-servers"
  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${var.resource_name_prefix}-consul-servers-sg" },
    var.common_tags,
  )
}

resource "aws_security_group_rule" "consul_server_rpc" {
  description       = "Allow Consul servers to reach each other on port 8300 for RPC requests"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_rpc_inbound" {
  description              = "Open up port 8300 on Consul servers so Consul clients can send them RPC requests"
  security_group_id        = aws_security_group.consul_servers.id
  type                     = "ingress"
  from_port                = 8300
  to_port                  = 8300
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.consul_clients.id
}

resource "aws_security_group_rule" "consul_client_serf_tcp_inbound" {
  description              = "Open up port 8301 on Consul servers so Consul clients can communicate with them using serf over tcp"
  security_group_id        = aws_security_group.consul_servers.id
  type                     = "ingress"
  from_port                = 8301
  to_port                  = 8301
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.consul_clients.id
}

resource "aws_security_group_rule" "consul_client_serf_udp_inbound" {
  description              = "Open up port 8301 on Consul servers so Consul clients can communicate with them using serf over udp"
  security_group_id        = aws_security_group.consul_servers.id
  type                     = "ingress"
  from_port                = 8301
  to_port                  = 8301
  protocol                 = "udp"
  source_security_group_id = aws_security_group.consul_clients.id
}

resource "aws_security_group_rule" "consul_serf_lan_tcp" {
  description       = "Allow Consul servers to use Serf over TCP"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_serf_lan_udp" {
  description       = "Allow Consul servers to use Serf over UDP"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "consul_http_api" {
  description       = "Allow Consul servers to reach other over HTTP API"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_dns_tcp" {
  description       = "Allow Consul servers to reach each other on Consul DNS over TCP"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_dns_udp" {
  description       = "Allow Consul servers to reach each other on Consul DNS over UDP"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "consul_server_ssh_inbound" {
  count             = var.allowed_inbound_cidrs_ssh != null ? 1 : 0
  description       = "Allow specified CIDRs SSH access to Consul servers"
  security_group_id = aws_security_group.consul_servers.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_inbound_cidrs_ssh
}

resource "aws_security_group_rule" "consul_servers_outbound" {
  description       = "Allow Consul servers to send outbound traffic"
  security_group_id = aws_security_group.consul_servers.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_template" "consul_servers" {
  name          = "${var.resource_name_prefix}-consul-servers"
  image_id      = var.user_supplied_ami_id != null ? var.user_supplied_ami_id : data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null
  user_data     = var.userdata_script
  vpc_security_group_ids = [
    aws_security_group.consul_servers.id,
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
    name = var.aws_iam_instance_profile
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "consul_servers" {
  name                = "${var.resource_name_prefix}-consul-servers"
  min_size            = var.server_count
  max_size            = var.server_count
  desired_capacity    = var.server_count
  vpc_zone_identifier = var.consul_subnets

  launch_template {
    id      = aws_launch_template.consul_servers.id
    version = "$Latest"
  }

  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.resource_name_prefix}-consul-server"
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

# The following security group and security group rules
# are being made to provide a default security group for
# users to to provide as input when they are creating
# clients so they can communicate properly with the
# servers that this module creates

resource "aws_security_group" "consul_clients" {
  name   = "${var.resource_name_prefix}-consul-clients"
  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${var.resource_name_prefix}-consul-clients-sg" },
    var.common_tags,
  )
}

resource "aws_security_group_rule" "consul_client_serf_lan_tcp" {
  description       = "Allow Consul clients to use Serf over TCP"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_serf_lan_udp" {
  description       = "Allow Consul clients to use Serf over UDP"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_http_api" {
  description       = "Allow Consul clients to reach other over HTTP API"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_dns_tcp" {
  description       = "Allow Consul clients to reach each other on Consul DNS over TCP"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_dns_udp" {
  description       = "Allow Consul clients to reach each other on Consul DNS over UDP"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "consul_client_ssh_inbound" {
  count             = var.allowed_inbound_cidrs_ssh != null ? 1 : 0
  description       = "Allow specified CIDRs SSH access to Consul clients"
  security_group_id = aws_security_group.consul_clients.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_inbound_cidrs_ssh
}

resource "aws_security_group_rule" "consul_clients_outbound" {
  description       = "Allow Consul clients to send outbound traffic"
  security_group_id = aws_security_group.consul_clients.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
