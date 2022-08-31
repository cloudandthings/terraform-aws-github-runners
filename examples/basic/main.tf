module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  github_url = "https://github.com/my-org"

  # Naming for all created resources
  naming_prefix = "test-github-runner"

  ssm_parameter_name = "/github/runner/token"

  # 2 cores, so 2 ephemeral runners will start in parallel.
  ec2_instance_type = "t3.micro"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
