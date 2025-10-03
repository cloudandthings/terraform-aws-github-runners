# GitHub Copilot Instructions

## Project Overview

This repository contains a Terraform module that deploys GitHub Action runners using AWS CodeBuild. The module creates serverless, cost-effective GitHub runners that scale automatically and are billed only when in use.

### Key Components

- **AWS CodeBuild Projects**: Ephemeral runners that self-configure as GitHub runners
- **GitHub Webhooks**: Trigger CodeBuild projects when GitHub Actions are triggered
- **AWS IAM Roles**: Manage permissions for CodeBuild projects
- **AWS CloudWatch Logs**: Store build logs
- **Optional ECR Integration**: Support for custom Docker images

### Architecture

The module creates an AWS CodeBuild Project and a webhook in a specific GitHub repository. When a GitHub Action is triggered, the webhook triggers the CodeBuild project, which self-configures as a GitHub runner and executes the workflow commands.

## Technology Stack

- **Terraform**: >= 0.14.0
- **AWS Provider**: >= 5, < 7
- **AWS Services**: CodeBuild, IAM, CloudWatch, ECR (optional), VPC (optional)
- **Languages**: HCL (Terraform), Python (for tooling)

## Development Guidelines

### Code Style

- Follow Terraform best practices and naming conventions
- Use descriptive variable names and add clear descriptions
- Add validation rules to variables where appropriate
- Keep resources organized in separate files (main.tf, variables.tf, outputs.tf, iam.tf, logs.tf, etc.)
- Use locals for computed values and to avoid repetition
- Add comments only when necessary to explain complex logic

### File Structure

- `main.tf`: Core CodeBuild and webhook resources
- `variables.tf`: Input variables with validation
- `outputs.tf`: Module outputs
- `iam.tf`: IAM roles and policies
- `logs.tf`: CloudWatch log group configuration
- `data.tf`: Data sources
- `locals.tf`: Local values
- `versions.tf`: Terraform and provider version constraints
- `examples/`: Example configurations (basic, advanced, addition-iam-policies, multiple-runners)

### Required Variables

- `name`: Name prefix for all created resources
- `source_location`: GitHub repository URL (e.g., https://github.com/my-org/my-repo.git)

### Optional Variables

- `description`: Short description of the project
- `github_personal_access_token`: GitHub PAT for authentication
- `github_personal_access_token_ssm_parameter`: SSM parameter containing GitHub PAT
- `github_app_id_ssm_parameter`: SSM parameter for GitHub App ID
- `github_app_installation_id_ssm_parameter`: SSM parameter for GitHub App installation ID
- `github_app_pem_file_ssm_parameter`: SSM parameter for GitHub App PEM file
- `vpc_id`: VPC ID for CodeBuild instances
- `subnet_ids`: Subnet IDs for CodeBuild instances
- `environment_type`: Build environment type (default: LINUX_CONTAINER)
- `environment_compute_type`: Compute resources (default: BUILD_GENERAL1_SMALL)
- `environment_image`: Docker image (defaults to aws/codebuild/amazonlinux2-x86_64-standard:5.0)
- `create_ecr_repository`: Whether to create an ECR repository
- `build_timeout`: Build timeout in minutes (default: 5)

## Testing and Validation

### Pre-commit Hooks

Always run pre-commit hooks before committing:

```bash
pre-commit run -a
```

Pre-commit hooks include:
- Terraform formatting (`terraform fmt`)
- Terraform validation (`terraform validate`)
- Terraform documentation generation (`terraform-docs`)
- Security scanning (tfsec, checkov)
- Linting (tflint)

### Documentation

- README.md is auto-generated using `terraform-docs`
- Update documentation when changing variables, outputs, or resources
- Example READMEs are also auto-generated

### Examples

Test changes against example configurations:
- `examples/basic/`: Minimal configuration
- `examples/advanced/`: Advanced configuration with custom settings
- `examples/addition-iam-policies/`: Custom IAM policy example
- `examples/multiple-runners/`: Multiple runner configuration

## Contribution Workflow

### Pull Request Process

1. Update README.md with details of changes (if applicable)
2. Add appropriate tests
3. Run pre-commit hooks: `pre-commit run -a`
4. Ensure CI tests pass
5. Wait for review and address feedback

### Semantic Commit Messages

Use conventional commit prefixes:
- `feat:` for new features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `docs:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purposes
- `chore:` for maintenance tasks (skipped in changelog)

### CI/CD

GitHub Actions workflows:
- `pre-commit-and-tests.yml`: Runs pre-commit hooks and tests
- `pr-title.yml`: Validates PR title format
- `release-please.yml`: Automated releases and changelog generation
- `terraform-min-max.yml`: Tests Terraform version compatibility

## Common Tasks

### Adding a New Variable

1. Add variable definition in `variables.tf` with:
   - Type specification
   - Description
   - Default value (if optional)
   - Validation rules (if applicable)
2. Use the variable in appropriate resource files
3. Run `pre-commit run -a` to update documentation
4. Add example usage if significant

### Adding a New Resource

1. Add resource in appropriate file (e.g., `main.tf`, `iam.tf`)
2. Consider if the resource should be conditional (use `count` or `for_each`)
3. Add any necessary outputs in `outputs.tf`
4. Add variables if configuration is needed
5. Update examples if the feature is significant
6. Run pre-commit hooks to update documentation

### Modifying IAM Policies

1. IAM resources are in `iam.tf`
2. Use `aws_iam_policy_document` data sources for policy documents
3. Test with examples that exercise the permissions
4. Consider security implications and principle of least privilege

### Working with Examples

1. Examples are in `examples/` directory
2. Each example has its own Terraform configuration
3. Examples should be self-contained and runnable
4. Update example READMEs (auto-generated by terraform-docs)

## Security Considerations

- Never commit secrets or credentials
- Use AWS SSM Parameter Store or GitHub App authentication
- Follow principle of least privilege for IAM policies
- Review security scanning results from tfsec and checkov
- VPC configuration is optional but recommended for isolation

## Important Notes

- CodeBuild images starting with `aws/codebuild/` use CODEBUILD credentials, others use SERVICE_ROLE
- ECR repositories can be created by the module or referenced by name
- Default ECR image tag is `latest` when using ECR
- Build timeout is configurable (5-2160 minutes)
- Module supports multiple authentication methods to GitHub
- Previous EC2-based version moved to separate repository: terraform-aws-github-runners-ec2

## Helpful Commands

```bash
# Format Terraform code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run all pre-commit hooks
pre-commit run -a

# Generate documentation
terraform-docs markdown table --config .tfdocs-config.yml --output-file README.md .

# Security scanning
tfsec .
checkov -d .
```

## Resources

- [Repository README](../README.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [GitHub Authentication Setup](../docs/GITHUB-AUTH-SETUP.md)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
