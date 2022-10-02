locals {
  common_tags = {
    environment = module.dev_envs.aws_accounts[terraform.workspace]["account-name"]
    owner       = "DevOps"
    email       = "devops@test.com"
    project     = "dev-env"
  }

  public_host = [
    module.dev_envs.aws_accounts[terraform.workspace]["subdomain"],
    "*.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}"
  ]

  public_hosts = concat(local.public_host)

  private_host = [
    "k8s.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}",
    "*.k8s.${module.dev_envs.aws_accounts[terraform.workspace]["subdomain"]}"
  ]

  private_hosts = concat(local.private_host)
}
