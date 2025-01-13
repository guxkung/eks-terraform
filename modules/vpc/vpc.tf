data "aws_internet_gateway" "gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id = var.vpc_id
  for_each = {
    for index, subnet in var.subnets :
    index => subnet
  }
  cidr_block = each.value["cidr_block"]
  tags = {
    Name = each.value["name"]
  }
}

resource "aws_route_table" "private" {
  #count                     = length(var.subnets)
  vpc_id = var.vpc_id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.gw.id
  }

  tags = {
    Name = "private-rtable"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

#resource "aws_nat_gateway" "single_nat_gw" {
#  allocation_id =  aws_eip.nat.id
#  subnet_id = var.public_subnet_id
#  
#  depends_on = [aws_internet_gateway.gw]
#}

#resource "aws_eip" "nat" {
#  depends_on = [aws_internet_gateway.gw]
#}
