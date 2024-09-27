resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.public_route_table_cidr_block
    gateway_id = aws_internet_gateway.main.id
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.public_route_table_tags
}

resource "aws_route_table_association" "public" {
  for_each       = { for subnet in var.public_subnets : index(var.public_subnets, subnet) => aws_subnet.public[index(var.public_subnets, subnet)].id }
  route_table_id = aws_route_table.public.id
  subnet_id      = each.value
}