output "subnet_ids" {
  value = [ for o in aws_subnet.private_subnets : o.id ]
}
