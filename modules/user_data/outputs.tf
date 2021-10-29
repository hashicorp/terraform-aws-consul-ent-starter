output "consul_userdata_server_base64_encoded" {
  value = base64encode(local.consul_user_data_server)
}

