data "aws_vpc" "workload" {
  id = var.vpc_id
}

resource "aws_security_group" "allow_vpc_cidr_to_eks_endpoint" {
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = data.aws_vpc.workload.cidr_block_associations[*].cidr_block
  }
  vpc_id = var.vpc_id
}

