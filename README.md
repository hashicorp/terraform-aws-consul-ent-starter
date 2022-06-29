# Consul Enterprise AWS Module

This is a Terraform module for provisioning Consul Enterprise on AWS. This
module defaults to setting up a cluster with 5 server nodes (as recommended by
the [Consul Reference
Architecture](https://learn.hashicorp.com/tutorials/consul/reference-architecture#failure-tolerance).

## About This Module
This module implements the [Consul Reference
Architecture](https://learn.hashicorp.com/tutorials/consul/reference-architecture)
on AWS using the Enterprise version of Consul 1.10+.

## How to Use This Module

- Ensure your AWS credentials are [configured
  correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  and have permission to use the following AWS services:
    - Amazon EC2
    - AWS Identity & Access Management (IAM)
    - AWS Key Management System (KMS)
    - Amazon Simple Storage Service (S3)
    - Amazon Secrets Manager
    - AWS Systems Manager Session Manager (optional - used to connect to EC2
      instances with session manager using the AWS CLI)
    - Amazon VPC

- This module assumes you have an existing VPC along with AWS secrets manager
  secrets that contain TLS certs, a gossip encryption key, and an ACL token. If
  you do not, you may use the following
  [quickstart](https://github.com/hashicorp/terraform-aws-consul-ent-starter/tree/main/examples/prereqs_quickstart)
  to deploy these resources.

- To deploy into an existing VPC, ensure the following components exist and are
  routed to each other correctly:
  - Three public subnets
  - Three [NAT
    gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
    (one in each public subnet)
  - Three private subnets

```hcl
provider "aws" {
  # your AWS region
  region = "us-east-1"
}

module "consul-ent" {
  source = "github.com/hashicorp/terraform-aws-consul-ent-starter"

  # prefix for tagging/naming AWS resources
  resource_name_prefix = "test"
  # VPC ID you wish to deploy into
  vpc_id               = "vpc-abc123xxx"
  # private subnet IDs are required and allow you to specify which
  # subnets you will deploy your Consul nodes into
  private_subnet_ids = [
    "subnet-0xyz",
    "subnet-1xyz",
    "subnet-2xyz",
  ]

  consul_license_filepath = "/Users/user/Downloads/consul.hclic"

  # AWS Secrets Manager ARN where default Consul server ACL token is stored
  secrets_manager_arn_acl_token_server = "arn:aws::secretsmanager:abc123xxx"
  # AWS Secrets Manager ARN where Consul gossip encryption key is stored
  secrets_manager_arn_gossip           = "arn:aws::secretsmanager:abc123xyx"
  # AWS Secrets Manager ARN where TLS certs are stored
  secrets_manager_arn_tls              = "arn:aws::secretsmanager:abc123xyy"
}
```

  - Run `terraform init` and `terraform apply`

  - You must [bootstrap](https://www.consul.io/commands/acl/bootstrap) your
    Consul cluster's ACL system after you create it. Begin by logging into your
    Consul cluster using one of the following methods:
      - Using [Session
        Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager.html)
      - SSH (you must provide the optional SSH key pair through the `key_name`
        variable and set a value for the `allowed_inbound_cidrs_ssh` variable.
          - Please note this Consul cluster is not public-facing. If you want to
            use SSH from outside the VPC, you are required to establish your own
            connection to it (VPN, etc).

  - To bootstrap the ACL system, run the following commands:

```
$ consul acl bootstrap
```

  - Please securely store the bootstrap token (shown as the SecretID) the Consul returns to you.
  - Use the bootstrap token to create an appropriate policy for your Consul
    servers and associate their token with it. The value of the `node_prefix`
    rule in the following ACL policy example should be something that actually
    matches what your Consul server node names begin with: 

```
export CONSUL_HTTP_TOKEN="<your bootstrap token>"
cat << EOF > consul-servers-policy.hcl
node_prefix "dev-consul-server" {
  policy = "write"
}

operator = "write"
EOF
consul acl policy create -name consul-servers -rules @consul-servers-policy.hcl
consul acl token create -policy-name consul-servers -secret "<your server token in acl_tokens_secret_id>"
unset CONSUL_HTTP_TOKEN
```

  - To check the status of your Consul cluster, run the
    [list-peers](https://www.consul.io/commands/operator/raft#list-peers)
    command:

```
$ consul operator raft list-peers
```

- Now clients can be configured to connect to the cluster. For an example, see
  the following code in the
  [examples](https://github.com/hashicorp/terraform-aws-consul-ent-starter/tree/main/examples/client)
  directory.

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-aws-consul-ent-starter/blob/main/LICENSE)
for more details.
