
# Outputs
output "ec2_public_ip" {
  value = module.instance.public_ip
}

output "security_group_id" {
  value = module.security_group.id
}

output "subnet_id" {
  value = module.subnet.subnet_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "internet_gateway_id" {
  value = module.internet_gateway.internet_gateway_id
}

output "route_table_id" {
  value = module.route_table.route_table_id
}

output "ssh_command" {
  value = "ssh -i ../keys/infrastructure-20230105.pem ubuntu@${module.instance.public_ip}"
}