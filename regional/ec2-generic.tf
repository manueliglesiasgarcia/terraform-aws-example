resource "aws_key_pair" "root_key" {
  key_name   = "aws-${module.dev_envs.aws_accounts[terraform.workspace]["account-name"]}-root-key"
  public_key = module.dev_envs.aws_accounts[terraform.workspace]["root_public_key"]
}