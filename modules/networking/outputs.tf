output "consul_subnet_ids" {
  value = data.aws_subnet_ids.consul.ids
}

output "vpc_id" {
  value = data.aws_vpc.selected.id
}

