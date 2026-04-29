data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_internet_gateway" "gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id = var.vpc_id
  #for_each = {
  #  for index, subnet in var.subnets :
  #  index => subnet
  #}
  #cidr_block = each.value["cidr_block"]
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  tags = {
    Name = "Subnet-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/test-cluster" = "shared"
    "karpenter.sh/discovery" = "karpenter-blueprints"
  }
  enable_resource_name_dns_a_record_on_launch = true
  count             = length(data.aws_availability_zones.available.names)
  availability_zone   = data.aws_availability_zones.available.names[count.index]
}
    #Name = each.value["name"]

resource "aws_route_table" "private" {
  #count                     = length(var.subnets)
  vpc_id = var.vpc_id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.single_nat_gw.id
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

resource "aws_nat_gateway" "single_nat_gw" {
  allocation_id =  aws_eip.nat.id
  subnet_id = var.public_subnet_id
  
  depends_on = [data.aws_internet_gateway.gw]
}

resource "aws_eip" "nat" {
  depends_on = [data.aws_internet_gateway.gw]
}
