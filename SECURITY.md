# Security Policy

## Reporting a Vulnerability

We take the security of terraform-aws-github-runners seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them by:

1. **Opening a security advisory**: Use GitHub's [Security Advisory](https://github.com/cloudandthings/terraform-aws-github-runners/security/advisories) feature (preferred method)
2. **Email**: If you prefer, you can email the maintainers directly through the contact information in the repository

Please include the following information in your report:

- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 3 business days
- **Communication**: We will keep you informed about the progress of fixing the vulnerability
- **Timeline**: We aim to resolve critical vulnerabilities within 30 days
- **Credit**: If you wish, we will publicly acknowledge your contribution once the vulnerability is fixed

### Disclosure Policy

- We will work with you to understand and resolve the issue quickly
- We request that you give us a reasonable amount of time to fix the vulnerability before any public disclosure
- We will coordinate with you on the timing of public disclosure
- We will credit you in our security advisory (unless you prefer to remain anonymous)

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 3.x     | :white_check_mark: |
| 2.x     | :white_check_mark: |
| < 2.0   | :x:                |

We recommend always using the latest version to ensure you have the latest security patches.

## Security Best Practices

When using this module, please follow these security best practices:

### Authentication & Secrets

- **Never commit secrets**: Do not hardcode GitHub tokens or AWS credentials in your Terraform code
- **Use secure storage**: Store sensitive values in AWS Systems Manager Parameter Store or AWS Secrets Manager
- **GitHub App preferred**: Consider using GitHub App authentication instead of personal access tokens when possible
- **Rotate credentials**: Regularly rotate GitHub tokens and AWS credentials
- **Least privilege**: Use IAM roles with minimal required permissions

### Network Security

- **VPC configuration**: Deploy CodeBuild projects within a VPC when possible
- **Security groups**: Use restrictive security group rules
- **Private subnets**: Use private subnets for CodeBuild runners when possible
- **No public access**: Ensure CodeBuild projects are not publicly accessible

### IAM & Permissions

- **Principle of least privilege**: Grant only the minimum permissions required
- **Use IAM roles**: Leverage IAM roles instead of long-lived credentials
- **Permissions boundary**: Consider using IAM permissions boundaries
- **Review policies**: Regularly review and audit IAM policies attached to runners

### Logging & Monitoring

- **Enable CloudWatch Logs**: Always enable logging for audit trails
- **Log retention**: Set appropriate log retention policies
- **Monitor activity**: Set up CloudWatch alarms for suspicious activities
- **Encryption**: Use KMS encryption for logs when handling sensitive data

### Container Security

- **Scan images**: Regularly scan Docker images for vulnerabilities
- **Update base images**: Keep base images up to date with security patches
- **Minimal images**: Use minimal base images to reduce attack surface
- **Signed images**: Consider using signed container images

### Terraform State

- **Remote state**: Use remote state with encryption (e.g., S3 with KMS)
- **State locking**: Enable state locking to prevent concurrent modifications
- **Access control**: Restrict access to state files
- **Sensitive data**: Be aware that some values may be stored in plain text in state

### Code Scanning

This repository includes automated security scanning:

- **Trivy**: Scans for vulnerabilities in the infrastructure code
- **Checkov**: Performs static code analysis for security issues
- **TFSec**: Scans Terraform code for security issues
- **Pre-commit hooks**: Run security checks before commits

We recommend running these tools locally before submitting pull requests:

```bash
# Run all pre-commit checks
pre-commit run -a

# Run specific security scans
trivy config .
checkov -d .
tfsec .
```

## Known Security Considerations

### CodeBuild Credential Limitation

AWS CodeBuild allows only ONE GitHub credential per AWS account per region. Be aware of this limitation when managing multiple projects:

- The credential is shared across all CodeBuild projects in an account/region
- Individual projects can override the baseline credential if needed
- See [GitHub Authentication Setup](docs/GITHUB-AUTH-SETUP.md) for details

### ECR Image Security

When using custom ECR images:

- Ensure images are scanned for vulnerabilities
- Use immutable image tags
- Implement a lifecycle policy to clean up old images
- Regularly update and rebuild images with security patches

### Security Group Rules

The module creates default security group rules for CodeBuild. Review these rules and customize them based on your security requirements:

- Default egress allows all traffic (required for GitHub Actions to work)
- Ingress rules are minimal by default
- Consider additional restrictions based on your use case

## Security Updates

Security updates will be:

- Released as soon as possible after a vulnerability is confirmed
- Documented in the CHANGELOG.md
- Tagged with a new version following semantic versioning
- Announced in GitHub Security Advisories

## Additional Resources

- [AWS CodeBuild Security](https://docs.aws.amazon.com/codebuild/latest/userguide/security.html)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Terraform Security](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html#security)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

## Contact

For security concerns that are not vulnerabilities (questions, general security practices, etc.), please open a regular GitHub issue or discussion.

Thank you for helping keep terraform-aws-github-runners and its users safe!
