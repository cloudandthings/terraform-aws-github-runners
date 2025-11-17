module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name            = "github-runner-codebuild-test"
  source_location = "https://github.com/my-org/my-repo.git"

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  # Optional parameters
  ############################
  description = "Created by my-org/my-runner-repo.git"

  # testing purposes only
  github_personal_access_token = "example"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional: Add custom security group ingress rules to the default SG
  # These rules are added in addition to the default HTTPS (443) rule
  security_group_ingress_rules = [
    {
      from_port   = 1024
      to_port     = 65535
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16" # Replace with your VPC CIDR
      description = "Allow ephemeral ports from VPC"
    }
  ]
}
