resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  lifecycle {
    prevent_destroy = true
  }

  tags = var.private_route_table_tags
}

resource "aws_route_table_association" "private" {
  for_each       = { for subnet in var.private_subnets : index(var.private_subnets, subnet) => aws_subnet.private[index(var.private_subnets, subnet)].id }
  route_table_id = aws_route_table.private.id
  subnet_id      = each.value
}

resource "aws_route" "nat_gw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.private_route_table_cidr_block
  nat_gateway_id         = aws_nat_gateway.main.id
}