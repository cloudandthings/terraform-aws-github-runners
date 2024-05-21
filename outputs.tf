output "codebuild_project" {
  value = {
    name = aws_codebuild_project.this.name
    arn  = aws_codebuild_project.this.arn
  }
  description = "Name and ARN of codebuild project, to be used when running GitHub Actions"
}

output "codebuild_role" {
  value = {
    name = aws_iam_role.this[0].name
    arn  = aws_iam_role.this[0].arn
  }
  description = "Name and ARN of codebuild role, to be used when running GitHub Actions"
}

output "ecr_repository" {
  value = {
    name = try(aws_ecr_repository.this[0].name, null)
    arn  = try(aws_ecr_repository.this[0].arn, null)
  }
  description = "Name and ARN of ECR repository, to be used when to push custom docker images for the codebuiild project"
}

output "custom_kms_key" {
  value = local.custom_kms_key
}
