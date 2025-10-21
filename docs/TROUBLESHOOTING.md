# Troubleshooting Guide

This guide covers common issues and their solutions when using terraform-aws-github-runners.

## Table of Contents

- [Authentication Issues](#authentication-issues)
- [CodeBuild Issues](#codebuild-issues)
- [Networking Issues](#networking-issues)
- [Docker Image Issues](#docker-image-issues)
- [GitHub Webhook Issues](#github-webhook-issues)
- [IAM Permission Issues](#iam-permission-issues)
- [Logging Issues](#logging-issues)
- [General Debugging](#general-debugging)

## Authentication Issues

### Error: "Could not find credentials"

**Symptoms:**
- CodeBuild project fails to connect to GitHub
- Webhook creation fails
- Error message about missing GitHub credentials

**Solutions:**

1. **Verify credential configuration:**
   - Ensure you've configured at least one authentication method
   - Check that the credential exists in the correct AWS region
   - Verify the credential has the correct permissions

2. **Check credential type:**
   ```hcl
   # Using Personal Access Token
   github_personal_access_token = var.github_token

   # OR using SSM Parameter
   github_personal_access_token_ssm_parameter = "/github/token"

   # OR using Secrets Manager
   github_secretsmanager_secret_arn = "arn:aws:secretsmanager:..."

   # OR using CodeConnection
   github_codeconnection_arn = "arn:aws:codeconnections:..."
   ```

3. **Verify token permissions:**
   - `repo` - Full control of private repositories
   - `admin:repo_hook` - Full control of repository hooks

### Error: "CodeBuild credential already exists"

**Symptoms:**
- Terraform fails when trying to create a new credential
- Error message: "ResourceAlreadyExistsException"

**Cause:**
AWS CodeBuild only allows ONE GitHub credential per AWS account per region.

**Solutions:**

1. **Use existing credential:**
   Remove the credential configuration from your module call - CodeBuild will use the existing baseline credential.

2. **Override for specific project:**
   ```hcl
   source_auth = {
     type     = "SECRETS_MANAGER"
     resource = "arn:aws:secretsmanager:region:account:secret:name"
   }
   ```

3. **Delete existing credential:**
   ```bash
   aws codebuild list-source-credentials
   aws codebuild delete-source-credentials --arn <credential-arn>
   ```

## CodeBuild Issues

### Error: "Build fails immediately"

**Symptoms:**
- CodeBuild project starts but fails within seconds
- No GitHub Actions logs visible

**Solutions:**

1. **Check GitHub runner registration:**
   - Verify the runner name matches your workflow: `codebuild-{name}-{run_id}-{run_attempt}`
   - Check GitHub Actions settings in your repository
   - Ensure the workflow is using the correct `runs-on` label

2. **Verify build timeout:**
   ```hcl
   build_timeout = 10  # Increase if builds are timing out
   ```

3. **Check CloudWatch Logs:**
   ```bash
   aws logs tail /aws/codebuild/your-runner-name --follow
   ```

### Error: "DOWNLOAD_SOURCE failed"

**Symptoms:**
- Build fails at source download phase
- Error about git clone or authentication

**Solutions:**

1. **Verify source location:**
   ```hcl
   source_location = "https://github.com/owner/repo.git"  # Must end with .git
   ```

2. **Check repository permissions:**
   - Ensure the GitHub token has access to the repository
   - Verify the repository exists and is not archived

3. **Check network connectivity:**
   - If using VPC, ensure NAT Gateway or internet access is configured
   - Verify security group rules allow outbound HTTPS

### Error: "Image pull failed"

**Symptoms:**
- Build fails with image pull errors
- Error message about Docker image not found

**Solutions:**

1. **For ECR images:**
   ```bash
   # Verify image exists
   aws ecr describe-images --repository-name your-repo-name --image-ids imageTag=latest

   # Check IAM permissions for ECR
   ```

2. **For CodeBuild images:**
   ```hcl
   environment_image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
   ```

3. **For custom Docker Hub images:**
   - Verify the image name is correct
   - Check if the image requires authentication

## Networking Issues

### Error: "VPC configuration failed"

**Symptoms:**
- Build fails when VPC is configured
- Network interface creation errors

**Solutions:**

1. **Verify VPC configuration:**
   ```hcl
   vpc_id     = "vpc-xxxxx"
   subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]  # Use private subnets
   ```

2. **Check NAT Gateway:**
   - CodeBuild needs internet access to reach GitHub
   - Private subnets must have a route to NAT Gateway or NAT Instance

3. **Verify IAM permissions:**
   The module automatically creates required VPC permissions, but if using a custom role:
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "ec2:CreateNetworkInterface",
       "ec2:DescribeNetworkInterfaces",
       "ec2:DeleteNetworkInterface",
       "ec2:DescribeSubnets",
       "ec2:DescribeSecurityGroups",
       "ec2:DescribeVpcs"
     ],
     "Resource": "*"
   }
   ```

### Error: "Security group attachment failed"

**Symptoms:**
- Cannot attach security group to CodeBuild project
- Security group errors in Terraform apply

**Solutions:**

1. **Verify security group VPC:**
   ```bash
   aws ec2 describe-security-groups --group-ids sg-xxxxx
   ```
   Security group must be in the same VPC as specified in `vpc_id`.

2. **Check security group rules:**
   ```hcl
   # Allow HTTPS outbound
   security_group_ids = [aws_security_group.custom.id]
   ```

## Docker Image Issues

### Error: "GitHub Actions not working with custom image"

**Symptoms:**
- Build starts but GitHub Actions steps fail
- Missing dependencies or tools

**Cause:**
Custom Docker images may not have all required GitHub Actions dependencies.

**Solutions:**

1. **Use a GitHub Actions-compatible base image:**
   ```dockerfile
   FROM ubuntu:22.04

   # Install required packages
   RUN apt-get update && apt-get install -y \
       curl \
       git \
       jq \
       nodejs \
       npm
   ```

2. **Install GitHub Actions dependencies:**
   - Node.js (for most actions)
   - Git (for checkout actions)
   - Docker (for container actions)
   - curl, jq (for API calls)

3. **Consider using the default CodeBuild image:**
   ```hcl
   # Let the module use the default
   # environment_image not specified
   ```

### Error: "ECR image not found"

**Symptoms:**
- CodeBuild cannot pull image from ECR
- Image tag not found

**Solutions:**

1. **Verify image was pushed:**
   ```bash
   aws ecr describe-images --repository-name your-repo-name
   ```

2. **Check image tag:**
   ```hcl
   environment_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/repo:v1.0"
   ```
   Default is `:latest` if not specified.

3. **Push an image:**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
   docker build -t your-repo-name .
   docker tag your-repo-name:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/your-repo-name:latest
   docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/your-repo-name:latest
   ```

## GitHub Webhook Issues

### Error: "Webhook creation failed"

**Symptoms:**
- Terraform apply fails at webhook creation
- Error about webhook permissions

**Solutions:**

1. **Verify GitHub token permissions:**
   - `admin:repo_hook` permission is required
   - Check token expiration

2. **Check repository settings:**
   - Ensure webhooks are allowed in repository settings
   - Verify you have admin access to the repository

3. **Manual webhook verification:**
   ```bash
   # Check webhook exists
   curl -H "Authorization: token YOUR_TOKEN" \
     https://api.github.com/repos/owner/repo/hooks
   ```

### Error: "Workflow not triggering"

**Symptoms:**
- Workflow file exists but builds don't start
- CodeBuild project never receives events

**Solutions:**

1. **Verify workflow syntax:**
   ```yaml
   jobs:
     my-job:
       runs-on: codebuild-YOUR_RUNNER_NAME-${{ github.run_id }}-${{ github.run_attempt }}
   ```

2. **Check webhook filter:**
   The module filters for `WORKFLOW_JOB_QUEUED` events only.

3. **Test workflow trigger:**
   - Push a commit or open a pull request
   - Check GitHub Actions tab for job status
   - Look for queued jobs

4. **Check CloudWatch Logs:**
   ```bash
   aws logs tail /aws/codebuild/your-runner-name --follow
   ```

## IAM Permission Issues

### Error: "Access Denied"

**Symptoms:**
- CodeBuild build fails with access denied
- Missing permissions for AWS services

**Solutions:**

1. **Check CloudWatch Logs permissions:**
   The module automatically creates required permissions, but verify:
   ```bash
   aws iam get-role-policy --role-name your-runner-name --policy-name your-runner-name-cloudwatch-logs
   ```

2. **Add custom permissions:**
   ```hcl
   iam_role_policies = {
     s3_access = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
   }
   ```

3. **Check permissions boundary:**
   If your organization uses permissions boundaries:
   ```hcl
   iam_role_permissions_boundary = "arn:aws:iam::123456789012:policy/BoundaryPolicy"
   ```

### Error: "Cannot assume role"

**Symptoms:**
- CodeBuild cannot assume the IAM role
- AssumeRole errors in logs

**Solutions:**

1. **Verify trust policy:**
   ```json
   {
     "Effect": "Allow",
     "Principal": {
       "Service": "codebuild.amazonaws.com"
     },
     "Action": "sts:AssumeRole"
   }
   ```

2. **Check account ID:**
   The module includes a condition to prevent confused deputy:
   ```json
   "Condition": {
     "StringEquals": {
       "aws:SourceAccount": "123456789012"
     }
   }
   ```

## Logging Issues

### Error: "Logs not appearing"

**Symptoms:**
- Build runs but no logs in CloudWatch
- Cannot debug build failures

**Solutions:**

1. **Verify log group exists:**
   ```bash
   aws logs describe-log-groups --log-group-name-prefix /aws/codebuild/
   ```

2. **Check log group configuration:**
   ```hcl
   create_cloudwatch_log_group = true
   cloudwatch_logs_group_name  = "/aws/codebuild/my-runner"
   ```

3. **Check IAM permissions:**
   Ensure the CodeBuild role has CloudWatch Logs permissions.

### Error: "Log retention policy failed"

**Symptoms:**
- Cannot set log retention
- Retention policy errors

**Solutions:**

1. **Use valid retention value:**
   ```hcl
   cloudwatch_log_group_retention_in_days = 14  # Valid: 1, 3, 5, 7, 14, 30, etc.
   ```

2. **Check KMS permissions:**
   If using KMS encryption:
   ```hcl
   kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/xxxxx"
   ```

## General Debugging

### Enable Detailed Logging

1. **CloudWatch Logs:**
   ```bash
   aws logs tail /aws/codebuild/your-runner-name --follow --format short
   ```

2. **Terraform Debug:**
   ```bash
   export TF_LOG=DEBUG
   terraform apply
   ```

3. **AWS CLI Debug:**
   ```bash
   aws codebuild batch-get-builds --ids <build-id> --debug
   ```

### Common Debugging Steps

1. **Check CodeBuild project:**
   ```bash
   aws codebuild batch-get-projects --names your-runner-name
   ```

2. **List recent builds:**
   ```bash
   aws codebuild list-builds-for-project --project-name your-runner-name
   ```

3. **Get build details:**
   ```bash
   aws codebuild batch-get-builds --ids <build-id>
   ```

4. **Check webhook:**
   ```bash
   aws codebuild list-webhooks --filter-group "[{\"type\":\"EVENT\",\"pattern\":\"WORKFLOW_JOB_QUEUED\"}]"
   ```

### Health Checks

**Test the runner:**

1. Create a simple workflow:
   ```yaml
   name: Test Runner
   on: [push]
   jobs:
     test:
       runs-on: codebuild-your-runner-name-${{ github.run_id }}-${{ github.run_attempt }}
       steps:
         - run: echo "Hello from CodeBuild!"
   ```

2. Push to trigger the workflow

3. Monitor in GitHub Actions and CloudWatch

## Getting Help

If you're still experiencing issues:

1. **Check existing issues:** [GitHub Issues](https://github.com/cloudandthings/terraform-aws-github-runners/issues)
2. **Search discussions:** [GitHub Discussions](https://github.com/cloudandthings/terraform-aws-github-runners/discussions)
3. **Review documentation:** [README.md](../README.md), [GitHub Auth Setup](GITHUB-AUTH-SETUP.md)
4. **Open a new issue:** Use the bug report template with detailed information

## Useful Resources

- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CodeBuild Troubleshooting](https://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html)
- [GitHub Actions Troubleshooting](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows)
