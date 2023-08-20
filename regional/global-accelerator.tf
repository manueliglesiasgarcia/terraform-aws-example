resource "aws_globalaccelerator_accelerator" "main_public_accelerator" {
  name            = module.dev_envs.aws_accounts[terraform.workspace]["account-name"]
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled = false
  }
}

resource "aws_globalaccelerator_listener" "main_public_http_https" {
  accelerator_arn = aws_globalaccelerator_accelerator.main_public_accelerator.id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "eks_public_alb" {
  listener_arn = aws_globalaccelerator_listener.main_public_http_https.id

  endpoint_group_region = data.aws_region.current.name

  health_check_port     = 443
  health_check_protocol = "TCP"

  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = module.eks_public_alb.lb_arn
    weight                         = 100
  }
}
