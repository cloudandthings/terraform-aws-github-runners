module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name            = "github-runner-packer-example"
  source_location = "https://github.com/my-org/my-repo.git"

  # Optional parameters
  ############################
  description = "GitHub runner with custom security group rules for Packer"

  # VPC configuration
  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Custom security group ingress rules for Packer
  # These rules are added to the default security group created by the module
  security_group_ingress_rules = [
    {
      from_port   = 1024
      to_port     = 65535
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16" # Replace with your VPC CIDR
      description = "Required to run Packer on CodeBuild (WinRM/SSH communicator)"
    }
  ]

  # testing purposes only
  github_personal_access_token = "example"
}
