output "codebuild_project_name" {
  value       = module.github_runner.codebuild_project_name
  description = "Name of the CodeBuild project"
}

output "security_group_id" {
  value       = module.github_runner.aws_security_group_id
  description = "ID of the security group created for the CodeBuild project"
}
