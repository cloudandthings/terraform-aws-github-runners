module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name = "github-runner-codebuild-test"
  source_location              = "https://github.com/my-org/my-repo.git"

  # Optional parameters
  ############################
  github_personal_access_token = "example"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
