module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  github_url = "https://github.com/my-org"

  naming_prefix = "test-github-runner"

  ec2_instance_type = "t3.micro"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]

  # Optional parameters
  ################################
  iam_instance_profile_arn = "arn:aws:iam::112233445566:role/terraform-aws-github-runners"

  software_packs = [
    "docker-engine",
    "node",
    "python3",
  ]

  ssm_parameter_name = "my/parameter"

  autoscaling_schedule_off_recurrences = ["0 20 * * *"]
  autoscaling_schedule_on_recurrences  = ["0 6 * * *"]
}
