module "user_data_1" {
  source = "../../modules/user_data"
  config = {
    aws_region             = "__TEST_REGION__"
    aws_ssm_parameter_name = "__TEST_SSM__"

    cloud_init_packages = []
    cloud_init_runcmds  = []

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"
  }
}

module "user_data_2" {
  source = "../../modules/user_data"
  config = {
    aws_region             = "__TEST_REGION__"
    aws_ssm_parameter_name = "__TEST_SSM__"

    cloud_init_packages = ["some_package1", "some_package2"]
    cloud_init_runcmds  = ["some_cmd_1", "some_cmd_2"]

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"
  }
}
