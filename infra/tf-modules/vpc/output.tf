output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "public_subnet_ids" {
  value       = [for subnet in var.public_subnets : aws_subnet.public[index(var.public_subnets, subnet)].id]
  description = "The IDs of the created public subnets"
}

output "private_subnet_ids" {
  value       = [for subnet in var.private_subnets : aws_subnet.private[index(var.private_subnets, subnet)].id]
  description = "The IDs of the created private subnets"
}

output "private_subnet_cidr_blocks" {
  value       = [for subnet in var.private_subnets : aws_subnet.private[index(var.private_subnets, subnet)].cidr_block]
  description = "The CIDR blocks of the created private subnets"
}

output "public_subnet_cidr_blocks" {
  value       = [for subnet in var.public_subnets : aws_subnet.public[index(var.public_subnets, subnet)].cidr_block]
  description = "The CIDR blocks of the created public subnets"
}

output "igw_id" {
  value       = aws_internet_gateway.main.id
  description = "The ID of the created Internet Gateway"
}

output "nat_gw_id" {
  value       = aws_nat_gateway.main.id
  description = "The ID of the created NAT Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "The ID of the created public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "The ID of the created private route table"
}

output "dhcp_options_id" {
  value       = aws_vpc_dhcp_options.main.id
  description = "The ID of the created DHCP options set"
}
