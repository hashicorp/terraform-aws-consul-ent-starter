#!/usr/bin/env bash

imds_token=$( curl -Ss -H "X-aws-ec2-metadata-token-ttl-seconds: 30" -XPUT 169.254.169.254/latest/api/token )
instance_id=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/instance-id )
local_ipv4=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/local-ipv4 )

# install package

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install -y consul-enterprise=${consul_version}+ent awscli jq

echo "Configuring system time"
timedatectl set-timezone UTC

# /opt/consul/tls should be readable by all users of the system
mkdir /opt/consul/tls
chmod 0755 /opt/consul/tls

# consul-key.pem should be readable by the consul group only
touch /opt/consul/tls/consul-key.pem
chown root:consul /opt/consul/tls/consul-key.pem
chmod 0640 /opt/consul/tls/consul-key.pem

secret_result_tls=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn_tls} --region ${region} --output text --query SecretString)

jq -r .consul_cert <<< "$secret_result_tls" | base64 -d > /opt/consul/tls/consul-cert.pem

jq -r .consul_ca <<< "$secret_result_tls" | base64 -d > /opt/consul/tls/consul-ca.pem

jq -r .consul_pk <<< "$secret_result_tls" | base64 -d > /opt/consul/tls/consul-key.pem

aws s3 cp "s3://${s3_bucket_consul_license}/${consul_license_name}" /opt/consul/consul.hclic

# consul.hclic should be readable by the consul group only
chown root:consul /opt/consul/consul.hclic
chmod 0640 /opt/consul/consul.hclic

gossip_encryption_key=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn_gossip} --region ${region} --output text --query SecretString)

acl_tokens=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn_acl_token} --region ${region} --output text --query SecretString)

cat << EOF > /etc/consul.d/consul.hcl
bootstrap_expect       = ${instance_count}
ca_file                = "/opt/consul/tls/consul-ca.pem"
cert_file              = "/opt/consul/tls/consul-cert.pem"
key_file               = "/opt/consul/tls/consul-key.pem"
data_dir               = "/opt/consul/data"
encrypt                = "$gossip_encryption_key"
license_path           = "/opt/consul/consul.hclic"
server                 = true
verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true

retry_join = [
  "provider=aws region=${region} tag_key=${name}-consul tag_value=cluster",
]

acl {
  enabled                  = true
  default_policy           = "deny"
  enable_token_persistence = true
  tokens {
    $acl_tokens 
  }
}

auto_encrypt {
  allow_tls = true
}

connect {
  enabled = true
}

ports {
  https = 8501
}

ui_config {
  enabled = false 
}

EOF

# consul.hcl should be readable by the consul group only
chown root:root /etc/consul.d
chown root:consul /etc/consul.d/consul.hcl
chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul

echo "Setup Consul profile"
cat <<PROFILE | sudo tee /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR="https://127.0.0.1:8501"
export CONSUL_CACERT="/opt/consul/tls/consul-ca.pem"
PROFILE
