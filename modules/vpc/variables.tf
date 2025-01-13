variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = list(object({
    cidr_block = string
    name       = string
  }))
}
variable "vpc_cidr" {
  type = string
}

#variable "public_subnet_id" {
#  type = string
#}
