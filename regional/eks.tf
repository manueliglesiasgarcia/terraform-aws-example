module "cluster_autoscaler_iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.3.0"
  create_role                   = true
  role_name                     = "${module.dev_envs.aws_accounts[terraform.workspace]["region-prefix"]}-eks-cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "${module.dev_envs.aws_accounts[terraform.workspace]["region-prefix"]}-eks-cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

data "aws_eks_cluster" "eks" {
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name  = module.eks.cluster_id
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"
  manage_aws_auth = false

  cluster_name    = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-cluster"
  cluster_version = "1.20"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

  ## https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
  enable_irsa = true

  workers_group_defaults = {
    ami_id = "ami-0ef0c69399dbb5f3f"
    target_group_arns = concat(
      module.eks_public_alb.target_group_arns,
      module.eks_private_alb.target_group_arns
    )

    tags = [
      {
        "key"                 = "k8s.io/cluster-autoscaler/${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-cluster"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/enabled"
        "value"               = "true"
        "propagate_at_launch" = true
      }
    ]
  }

  worker_additional_security_group_ids = [module.eks_nodes_custom_security_group.this_security_group_id]

  ##
  ## Create one ASG per private subnet
  ## See: https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#common-notes-and-gotchas
  ##

  worker_groups = [
    for private_subnet in module.vpc.private_subnets : {
      name          = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-worker-ondemand-${private_subnet}"
      instance_type = module.dev_envs.aws_accounts[terraform.workspace]["eks"]["ondemand_instance_type"]
      subnets = tolist([private_subnet])

      ami_id               = module.dev_envs.aws_accounts[terraform.workspace]["eks"]["ami"]

      asg_max_size         = module.dev_envs.aws_accounts[terraform.workspace]["eks"]["ondemand_max_size"]
      asg_min_size         = module.dev_envs.aws_accounts[terraform.workspace]["eks"]["ondemand_min_size"]
      asg_desired_capacity = module.dev_envs.aws_accounts[terraform.workspace]["eks"]["ondemand_desired_capacity"]

      kubelete_extra_args = "--node-labels=kubernetes.io/lifecycle=normal"
      public_ip           = false

      root_volume_type = "gp2"
    }
  ]

  tags = local.common_tags
}

resource "kubernetes_config_map" "aws_auth_configmap" {

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- "rolearn": "${module.eks.worker_iam_role_arn}"
  "username": "system:node:{{EC2PrivateDNSName}}"
  "groups":
    - "system:bootstrappers"
    - "system:nodes"
YAML
  }
  lifecycle {
    ignore_changes = [
      metadata["annotations"],metadata["labels"],
    ]
  }
}
