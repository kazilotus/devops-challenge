resource "aws_subnet" "public" {
  for_each          = { for ps in var.public_subnets : index(var.public_subnets, ps) => ps }
  cidr_block        = each.value
  availability_zone = "${var.region}${var.zones[each.key]}"
  vpc_id            = aws_vpc.main.id
  tags = merge(
    var.public_subnet_tags,
    tomap({ "Name" = "${var.public_subnet_tags.Environment}-${var.public_subnet_tags.Project}-public-subnet-1${var.zones[each.key]}" }),
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "private" {
  for_each          = { for ps in var.private_subnets : index(var.private_subnets, ps) => ps }
  cidr_block        = each.value
  availability_zone = "${var.region}${var.zones[each.key]}"
  vpc_id            = aws_vpc.main.id
  tags = merge(
    var.private_subnet_tags,
    tomap({ "Name" = "${var.private_subnet_tags.Environment}-${var.private_subnet_tags.Project}-private-subnet-1${var.zones[each.key]}" }),
  )
  lifecycle {
    prevent_destroy = true
  }
}
