output "consul_clients_sg_id" {
  description = "Security group ID that should be provided to Consul clients"
  value       = aws_security_group.consul_clients.id
}

output "consul_servers_sg_id" {
  description = "Security group ID of Consul servers"
  value       = aws_security_group.consul_servers.id
}
