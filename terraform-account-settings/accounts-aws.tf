locals {
  aws_accounts = {
    env_dev = {
      deploy-rds-from-snapshot = false
      deploy-rds               = true
      deploy-dns               = true
      deploy-ec2               = true

      account-id   = ""
      region       = "us-west-2"
      short-region = "uswe2"

      region-prefix = "uswe2"

      account-name = "env-dev"

      subdomain      = ""
      hosted_zone_id = ""

      root_public_key = ""

      vpc = {
        cidr = "10.20.0.0/20"

        azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
        private_subnets = ["10.20.0.0/23", "10.20.2.0/23", "10.20.4.0/23"]
        public_subnets  = ["10.20.15.0/24", "10.20.14.0/24", "10.20.13.0/24"]

        single_nat_gateway = false

        amazon_side_asn = 64517
      }

      eks = {
        ami = "ami-01a2cfbadc91647c7"
        # This values are per private subnet
        # One ASG is created per subnet and Cluster Autoscaler is used
        ondemand_instance_type    = "r5a.xlarge"
        ondemand_max_size         = 5
        ondemand_min_size         = 0
        ondemand_desired_capacity = 1

        spot_instance_types   = ["r5a.xlarge", "r5.xlarge"]
        spot_instance_pools   = 4
        spot_max_size         = 1
        spot_min_size         = 0
        spot_desired_capacity = 0
      }
    }
  }
}
