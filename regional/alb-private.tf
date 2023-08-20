module "eks_private_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.7.0"

  name = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-private-ingress"

  load_balancer_type         = "application"
  enable_deletion_protection = true

  internal = true

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  security_groups = [module.eks_private_alb_security_group.this_security_group_id]

  target_groups = [
    {
      name             = "eks-private-alb-ingress"
      backend_protocol = "HTTPS"
      backend_port     = 30443
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn =  module.private_domains_certificates[0].this_acm_certificate_arn
      action_type     = "fixed-response"
      ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Bad Request"
        status_code  = "400"
      }
    }
  ]

  tags = local.common_tags
}

## Add certificate
resource "aws_lb_listener_certificate" "eks_private_alb_cert" {
  count = 1

  listener_arn    = module.eks_private_alb.https_listener_arns[0]
  certificate_arn = module.private_domains_certificates[0].this_acm_certificate_arn
}

resource "aws_lb_listener_rule" "allow_only_private_domains" {
  count = length(module.eks_private_alb.https_listener_arns)

  listener_arn = module.eks_private_alb.https_listener_arns[count.index]
  priority     = 100 + count.index

  action {
    type             = "forward"
    target_group_arn = module.eks_private_alb.target_group_arns[count.index]
  }

  condition {
    host_header {
      values = local.private_hosts
    }
  }
}
