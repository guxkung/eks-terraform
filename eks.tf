module "vpc" {
  source = "./modules/vpc"
  vpc_id = var.vpc_id
  vpc_cidr = var.vpc_cidr
  subnets = var.subnets
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"
  cluster_name                    = "test-cluster"
  cluster_version                 = "1.31"
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  #  cluster_endpoint_public_access_cidrs	= ["YOUR_IP_CIDR_HERE"] # example public ip ["57.68.3.137/32"] or ["0.0.0.0/0"]
  vpc_id = var.vpc_id

  control_plane_subnet_ids                 = module.vpc.subnet_ids
  subnet_ids                               = module.vpc.subnet_ids
  enable_cluster_creator_admin_permissions = true
  cluster_encryption_config   = {}
  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  authentication_mode = "API_AND_CONFIG_MAP"
  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  depends_on = [module.vpc]
}
module "eks_blueprints_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  eks_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    #    eks-pod-identity-agent = {
    #      most_recent = true
    #      configuration_values = jsonencode({
    #        "agent" : {
    #          "additionalArgs" : {
    #            "-b" : "169.254.170.23"
    #          }
    #        }
    #      })
    #    }
  }
  depends_on = [module.vpc]
}
#module "vpc_cni_irsa_role" {
#  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#  role_name = "identity-sa-vpc-cni-role"
#  attach_vpc_cni_policy = true
#  vpc_cni_enable_ipv4   = true
#  oidc_providers = {
#    main = {
#      provider_arn               = module.eks.oidc_provider_arn
#      namespace_service_accounts = ["kube-system:aws-node"]
#    }
#  }
#}
