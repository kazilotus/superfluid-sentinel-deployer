output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "List of IDs of subnet"
  value       = aws_subnet.ecs_subnet[*].id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ecs_security_group.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}
