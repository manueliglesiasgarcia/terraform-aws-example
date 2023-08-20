resource "aws_eip" "nat" {
  count = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["single_nat_gateway"] ? 1 : length(module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["private_subnets"])

  vpc = true
}

##
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#vpc-subnet-tagging
##
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-dev-vpc"
  cidr = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["cidr"]

  azs             = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["azs"]
  private_subnets = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["private_subnets"]
  public_subnets  = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["public_subnets"]

  enable_dns_hostnames = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  # This one takes precedence before the above
  single_nat_gateway  = module.dev_envs.aws_accounts[terraform.workspace]["vpc"]["single_nat_gateway"]
  reuse_nat_ips       = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = aws_eip.nat.*.id # <= IPs specified here as input to the module

  tags = local.common_tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-eks-cluster" = "shared",
    "kubernetes.io/role/elb"                                                                                         = "1"
  }
}

