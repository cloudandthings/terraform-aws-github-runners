# Provide default values for all optional fields
module "user_data_1" {
  source = "../../../modules/user_data"
  config = {
    region               = "TEST_REGION"
    ssm_parameter_name   = "__TEST_PARAMETER__"
    cloudwatch_log_group = ""

    cloud_init_packages    = []
    cloud_init_runcmds     = []
    cloud_init_write_files = []
    cloud_init_other       = ""

    per_instance_runner_count = 0
    runner_name               = ""
    runner_group              = ""
    runner_labels             = []

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"
  }
}

# Provide test values for all optional fields
module "user_data_2" {
  source = "../../../modules/user_data"
  config = {
    region               = "TEST_REGION"
    ssm_parameter_name   = "__TEST_PARAMETER__"
    cloudwatch_log_group = "_TEST_CLOUDWATCH_LOG_GROUP_"

    cloud_init_packages    = ["some_package1", "some_package2"]
    cloud_init_runcmds     = ["some_cmd_1", "some_cmd_2"]
    cloud_init_write_files = ["some_text", "some_more_text"]
    cloud_init_other = yamlencode({
      some_section = { some_key = "some_value" }
    })

    per_instance_runner_count = 0
    runner_name               = "my_runner"
    runner_group              = "my_group"
    runner_labels             = ["label1", "label2"]

    github_url               = "__TEST_GITHUB_URL__"
    github_organisation_name = "__TEST_GITHUB_ORG_NAME__"
  }
}
