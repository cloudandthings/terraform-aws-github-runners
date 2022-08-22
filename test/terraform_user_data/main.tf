module "user_data_1" {
  source = "../../modules/user_data"
  config = {
    aws_region             = "__TEST_REGION__"
    aws_ssm_parameter_name = "__TEST_SSM__"

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"

    ssh_authorized_key = "__TEST_SSH_KEY__"
  }
}

module "user_data_2" {
  source = "../../modules/user_data"
  config = {
    aws_region             = "__TEST_REGION__"
    aws_ssm_parameter_name = "__TEST_SSM__"

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"

    ssh_authorized_key = ""
  }
}
