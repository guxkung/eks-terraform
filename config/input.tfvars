vpc_id = "vpc-06eb0dd81fd32ecf2"
#vpc_id = "vpc-0d1d2d08241e7fd9b"

subnets = [
  { "cidr_block" : "172.31.64.0/20", "name" : "private-subnet-a" },
  { "cidr_block" : "172.31.96.0/20", "name" : "private-subnet-b" },
  { "cidr_block" : "172.31.128.0/20", "name" : "private-subnet-c" }
]
vpc_cidr    = "172.31.0.0/16"
region      = "ap-southeast-7"
account_ids = ["955708081987"]

public_subnet_id = "subnet-037096a7295e64a83"
