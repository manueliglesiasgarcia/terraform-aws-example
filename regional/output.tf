output "route53_zone_name_servers" {
  value = data.aws_route53_zone.subdomain.*.name_servers
}

output "route53_zone_name" {
  value = data.aws_route53_zone.subdomain.*.name
}

output "eks_config_map_aws_auth" {
  value = module.eks.config_map_aws_auth
}
