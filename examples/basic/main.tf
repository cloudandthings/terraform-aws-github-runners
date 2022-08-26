module "github_runner" {
  source = "../../"

  github_url = "https://github.com/my-org"

  region = "eu-west-1"

  naming_prefix = "test-github-runner"

  ec2_instance_type        = "t3.micro"
  iam_instance_profile_arn = "arn:aws:iam::112233445566:role/terraform-aws-github-runners"

  software_packs = [
    "python3",
    "docker-engine",
    "terraform",
    "terraform-docs",
    "tflint"
  ]

  autoscaling_schedule_off_recurrences = ["0 20 * * *"]
  autoscaling_schedule_on_recurrences  = ["0 6 * * *"]

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
