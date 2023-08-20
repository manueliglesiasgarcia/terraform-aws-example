data "aws_route53_zone" "subdomain" {
  count = 1

  zone_id = module.dev_envs.aws_accounts[terraform.workspace]["hosted_zone_id"]
}

##
# Public Ingress
##
resource "aws_route53_record" "eks_public_ingress" {
  count = module.dev_envs.aws_accounts[terraform.workspace]["deploy-dns"] ? 1 : 0

  zone_id = data.aws_route53_zone.subdomain[0].zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_globalaccelerator_accelerator.main_public_accelerator.dns_name
    zone_id                = aws_globalaccelerator_accelerator.main_public_accelerator.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "eks_public_ingress_wildcard" {
  count = module.dev_envs.aws_accounts[terraform.workspace]["deploy-dns"] ? 1 : 0

  zone_id = data.aws_route53_zone.subdomain[0].zone_id
  name    = "*"
  type    = "A"

  alias {
    name                   = aws_globalaccelerator_accelerator.main_public_accelerator.dns_name
    zone_id                = aws_globalaccelerator_accelerator.main_public_accelerator.hosted_zone_id
    evaluate_target_health = false
  }
}

##
# Private Ingress
##
resource "aws_route53_record" "eks_private_ingress" {
  count = !module.dev_envs.aws_accounts[terraform.workspace]["deploy-dns"] ? 1 : 0

  zone_id = data.aws_route53_zone.subdomain[0].zone_id
  name    = "k8s"
  type    = "A"

  alias {
    name                   = module.eks_private_alb.lb_dns_name
    zone_id                = module.eks_private_alb.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "eks_private_ingress_wildcard" {
  count = !module.dev_envs.aws_accounts[terraform.workspace]["deploy-dns"] ? 1 : 0

  zone_id = data.aws_route53_zone.subdomain[0].zone_id
  name    = "*.k8s"
  type    = "A"

  alias {
    name                   = module.eks_private_alb.lb_dns_name
    zone_id                = module.eks_private_alb.lb_zone_id
    evaluate_target_health = false
  }
}
