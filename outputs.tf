output "codebuild_project_name" {
  value       = aws_codebuild_project.this.name
  description = "Name of the CodeBuild project, to be used when running GitHub Actions"
}

output "codebuild_project_arn" {
  value       = aws_codebuild_project.this.arn
  description = "ARN of the CodeBuild project, to be used when running GitHub Actions"
}

output "codebuild_role_name" {
  value       = try(aws_iam_role.this[0].name, var.iam_role_name)
  description = "Name of the CodeBuild role, to be used when running GitHub Actions"
}

output "ecr_repository_name" {
  value       = try(aws_ecr_repository.this[0].name, null)
  description = "Name of the ECR repository, to be used when to push custom docker images for the CodeBuild project"
}

output "aws_security_group_id" {
  value       = try(aws_security_group.codebuild[0].id, null)
  description = "ID of the security group created for the CodeBuild project"
}

output "environment_image" {
  value       = local.environment_image
  description = "Docker image used for this CodeBuild project"
}

output "cloudwatch_log_group_name" {
  value       = try(aws_cloudwatch_log_group.codebuild[0].name, null)
  description = "Name of the CloudWatch log group for the CodeBuild project"
}
