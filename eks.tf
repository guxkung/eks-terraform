data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

locals {
  name = "karpenter-blueprints"
  node_iam_role_name = module.eks_blueprints_addons.karpenter.node_iam_role_name
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_id   = var.vpc_id
  vpc_cidr = var.vpc_cidr
  subnets  = var.subnets
  public_subnet_id = var.public_subnet_id
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
  cluster_encryption_config                = {}
  create_cloudwatch_log_group              = false
  cluster_enabled_log_types                = []

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
  eks_managed_node_groups = {
    mg = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]

      #create_security_group = false
      cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
      vpc_security_group_ids = [module.eks.node_security_group_id]

      subnet_ids   = module.vpc.subnet_ids
      max_size     = 2
      desired_size = 1
      min_size     = 1

      # Launch template configuration
      #create_launch_template = true              # false will use the default launch template
      #launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      labels = {
        intent = "control-apps"
      }
    }
  }
  #cluster_compute_config = {
  #  enabled    = true
  #  node_pools = ["general-purpose"]
  #}
  tags = {
    "karpenter.sh/discovery" = local.name
  }

  depends_on = [module.vpc]
}
module "eks_blueprints_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_karpenter  = true

  karpenter = {
    chart_version       = "1.1.1"
    #repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    #repository_password = data.aws_ecrpublic_authorization_token.token.password
  }
  karpenter_enable_spot_termination          = true
  karpenter_enable_instance_profile_creation = true
  karpenter_node = {
    iam_role_use_name_prefix = false
  }

  eks_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
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

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
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
