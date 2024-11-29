module "runners" {
  for_each = var.source_locations

  source = "../../"

  name                          = "${each.value.source_name}-github-runner"

  source_location               = each.value.source_location
  
  github_personal_access_token_ssm_parameter = var.github_personal_access_token_ssm_parameter

  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
}
