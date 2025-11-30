# Contributing to terraform-aws-github-runners

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

This project adheres to a Code of Conduct that we expect all contributors to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/terraform-aws-github-runners.git`
3. Add the upstream repository: `git remote add upstream https://github.com/cloudandthings/terraform-aws-github-runners.git`
4. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 0.14.0
- [pre-commit](https://pre-commit.com/) for code quality checks
- [mise](https://mise.jdx.dev/) (optional but recommended) for tool version management
- AWS Account for testing (optional)

### Using mise (Recommended)

This project uses [mise](https://mise.jdx.dev/) to manage tool versions. Install mise and run:

```bash
mise install
```

This will install all required tools as defined in `mise.toml`.

### Manual Installation

If not using mise, install the following tools:

- Terraform 1.5.7 or later
- Python 3.10.8 or later
- terraform-docs
- tflint
- pre-commit
- black
- ruff

### Install Pre-commit Hooks

Pre-commit hooks ensure code quality and consistency:

```bash
pre-commit install
```

## How to Contribute

### Reporting Bugs

- Use the GitHub issue tracker
- Search existing issues first to avoid duplicates
- Use the bug report template
- Include as much detail as possible:
  - Terraform version
  - AWS provider version
  - Steps to reproduce
  - Expected vs actual behavior
  - Relevant logs or error messages

### Suggesting Enhancements

- Use the GitHub issue tracker
- Use the feature request template
- Clearly describe the feature and its use case
- Explain why this enhancement would be useful

### Contributing Code

1. Pick an issue or create a new one
2. Comment on the issue to let others know you're working on it
3. Fork the repository and create a branch
4. Make your changes following our coding standards
5. Test your changes thoroughly
6. Run pre-commit checks
7. Submit a pull request

## Pull Request Process

1. **Update Documentation**: Update README.md and other relevant documentation
2. **Add Tests**: Include tests for new functionality (if applicable)
3. **Run Pre-commit**: Ensure all pre-commit checks pass
   ```bash
   pre-commit run -a
   ```
4. **Use Conventional Commits**: Follow the commit message format:
   - `feat:` - New features
   - `fix:` - Bug fixes
   - `docs:` - Documentation changes
   - `improvement:` - Enhancements to existing features
   - `refactor:` - Code refactoring
   - `test:` - Test additions or updates
   - `ci:` - CI/CD changes
   - `chore:` - Maintenance tasks (excluded from changelog)

5. **PR Title**: Use the same conventional commit format for PR titles
6. **Description**: Provide a clear description of changes
7. **Link Issues**: Reference related issues (e.g., "Fixes #123")
8. **Wait for Review**: Maintainers will review and provide feedback
9. **Address Feedback**: Make requested changes
10. **Merge**: Once approved, a maintainer will merge your PR

## Coding Standards

### Terraform

- Follow [Terraform best practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- Use meaningful variable and resource names
- Add descriptions to all variables and outputs
- Include validation rules where appropriate
- Use locals for computed values
- Keep resources organized in appropriate files:
  - `main.tf` - Core resources
  - `variables.tf` - Input variables
  - `outputs.tf` - Output values
  - `iam.tf` - IAM resources
  - `logs.tf` - Logging resources
  - `data.tf` - Data sources
  - `locals.tf` - Local values
  - `versions.tf` - Version constraints

### Code Formatting

- Run `terraform fmt -recursive` before committing
- Use 2 spaces for indentation
- Keep lines under 120 characters when possible

### Comments

- Add comments only when necessary to explain complex logic
- Use checkov skip comments with clear explanations
- Document any security-related decisions

### Security

- Never commit secrets or credentials
- Use AWS Systems Manager Parameter Store or Secrets Manager for sensitive values
- Follow the principle of least privilege for IAM policies
- Run security scanning tools (tfsec, checkov) before submitting

## Testing

### Pre-commit Tests

All pre-commit hooks must pass:

```bash
pre-commit run -a
```

This includes:
- Terraform formatting (`terraform fmt`)
- Terraform validation (`terraform validate`)
- Terraform documentation generation (`terraform-docs`)
- Security scanning (tfsec, checkov)
- Linting (tflint)
- Shell script checking (shellcheck)
- Python formatting (black, ruff)

### Manual Testing

Test your changes with the example configurations:

```bash
cd examples/basic
terraform init
terraform validate
terraform plan
```

### Security Scanning

Run security scans locally:

```bash
# Trivy scan
trivy config .

# Checkov scan
checkov -d .

# TFSec scan
tfsec .
```

## Documentation

### README Updates

The main README.md is partially auto-generated using `terraform-docs`. After changing variables, outputs, or resources:

```bash
terraform-docs markdown table --config .tfdocs-config.yml --output-file README.md .
```

Or simply run pre-commit which will update it automatically:

```bash
pre-commit run -a
```

### Example Documentation

Examples in the `examples/` directory have their own READMEs that are also auto-generated. The Python script handles this:

```bash
python examples/terraform-docs.py
```

### Writing Good Documentation

- Keep documentation clear and concise
- Include practical examples
- Document prerequisites and dependencies
- Explain the "why" not just the "how"
- Update documentation in the same PR as code changes

## Community

### Getting Help

- Check existing [issues](https://github.com/cloudandthings/terraform-aws-github-runners/issues)
- Read the [documentation](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/README.md)
- Review [examples](https://github.com/cloudandthings/terraform-aws-github-runners/tree/main/examples)

### Communication

- Be respectful and constructive
- Focus on the issue, not the person
- Assume good intentions
- Ask questions when something is unclear

## Release Process

Releases are automated using [Release Please](https://github.com/googleapis/release-please):

- Conventional commit messages are used to generate changelogs
- Version bumps are automatic based on commit types
- CHANGELOG.md is automatically updated
- Maintainers merge the release PR to create a new release

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing! 🎉
