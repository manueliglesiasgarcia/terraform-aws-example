module "public_domains_certificates" {
  count = 1
  source  = "terraform-aws-modules/acm/aws"
  version = "2.14.0"

  wait_for_validation  = false
  validate_certificate = true

  domain_name = module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]
  zone_id     = data.aws_route53_zone.subdomain[0].id

  subject_alternative_names = [
    "*.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}"
  ]

  tags = local.common_tags
}

##
# Private Ingress
##

module "private_domains_certificates" {
  count = 1

  source  = "terraform-aws-modules/acm/aws"
  version = "2.14.0"

  wait_for_validation  = false
  validate_certificate = true

  domain_name = "k8s.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}"
  zone_id     = data.aws_route53_zone.subdomain[0].id

  subject_alternative_names = [
    "*.k8s.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}",
  ]

  tags = local.common_tags
}