module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  source_location              = "https://github.com/my-org/my-repo.git"
  github_personal_access_token = "example"

  # Naming for all created resources
  name = "github-runner-codebuild-test"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
