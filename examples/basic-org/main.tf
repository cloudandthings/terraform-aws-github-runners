module "github_runner" {
  source = "../../"

  # Required parameters
  ############################
  # Naming for all created resources
  name                = "github-runner-codebuild-test"
  source_location     = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
  source_organization = "cloudandthings"

  # Environment image is not specified so it will default to:
  # "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  # Optional parameters
  ############################
  description = "Created by my-org/my-runner-repo.git"

  github_personal_access_token = "example"

  vpc_id     = "vpc-0ffaabbcc1122"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
