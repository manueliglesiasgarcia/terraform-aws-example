module "eks_nodes_custom_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-nodes-custom"
  description = "Additional security group for EKS Worker Nodes: E.g: ALB, VPN"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 32443
      to_port                  = 32443
      protocol                 = "tcp"
      description              = "Public Ingress"
      source_security_group_id = module.eks_public_alb_security_group.this_security_group_id
    },
    {
      from_port                = 30443
      to_port                  = 30443
      protocol                 = "tcp"
      description              = "Private Ingress"
      source_security_group_id = module.eks_private_alb_security_group.this_security_group_id
    },
  ]

  tags = local.common_tags
}

module "eks_public_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-public-ingress"
  description = "Security group for the public ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-tcp"]

  tags = local.common_tags
}

module "eks_private_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-private-ingress"
  description = "Security group for the private ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-tcp"]

  tags = local.common_tags
}

