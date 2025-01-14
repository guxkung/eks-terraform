vpc_id                   = "YOUR_VPC_ID_HERE"
subnets = [
  { "cidr_block" : "CIDR_A_HERE", "name" : "private-subnet-a" },
  { "cidr_block" : "CIDR_B_HERE", "name" : "private-subnet-b" },
  { "cidr_block" : "CIDR_C_HERE", "name" : "private-subnet-c" }
]
vpc_cidr = "VPC_CIDR_HERE"

region      = "YOUR_REGION"
account_ids = ["YOUR_ACCOUNT_ID"]

public_subnet_id = "PUBLIC_SUBNET_ID_HERE"
