# Setting Up Authentication to GitHub

## Overview

This guide covers the configuration of GitHub authentication for AWS CodeBuild projects. The primary authentication method documented here is personal access tokens, though OAuth is also supported by CodeBuild.

> **Important:** CodeBuild supports only one GitHub credential per AWS account per region. This credential is automatically shared across all CodeBuild projects within that account and region.

## Prerequisites

Before proceeding, you should understand that:
- A single GitHub credential applies to all CodeBuild projects in the same AWS account and region
- The credential needs to be configured only once per region, not per project
- Multiple approaches are available for managing this credential

## Step 1: Create a GitHub Personal Access Token

Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) through the GitHub console.

Ensure your token has the [required permissions](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html#access-tokens-github-prereqs) as specified in the AWS CodeBuild documentation.

## Step 2: Add the Credential to CodeBuild

Choose one of the following approaches based on your requirements and organizational practices.

### Option A: Manual Configuration via AWS Console or CLI (Recommended)

This approach is recommended if you prefer not to store credentials in Terraform state.

Follow the [AWS documentation](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-create-github.html) to add the credential through the AWS Console or CLI.

**When to use this option:**
- You need a quick setup without infrastructure-as-code dependencies

### Option B: Terraform Resource (Recommended for IaC)

This approach is recommended for if you want to manage infrastructure through Terraform.

Define an [`aws_codebuild_source_credential`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) resource in your Terraform project.

The token could be a SecretsManager secret ARN:

```terraform
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "SECRETS_MANAGER"
  server_type = "GITHUB"
  token       = "arn:aws:secretsmanager:region:account-id:secret:name"
}
```

Or you can provide the token value directly.

> **Security Note:** The token value is stored in Terraform state. Ensure your state backend is properly secured.

```terraform
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "my-token"
}
```

### Option C: Via This Module

This module can create the CodeBuild source credential on your behalf, if required.
You may use one of the following input variables:

#### AWS SecretsManager
```terraform
github_personal_access_token_secretsmanager_secret_arn = "arn:aws:secretsmanager:region:account-id:secret:name"
```

You store the token in AWS Secrets Manager, and provide the secret ARN as input.
The module does not read the secret, it passes the ARN to the CodeBuild credential resource.

#### Direct Token Value
```terraform
github_personal_access_token = "your-token-here"
```

You provide the token value as a string input.

> **Security Note:** Credentials will be stored in Terraform state.

#### AWS Systems Manager Parameter Store
```terraform
github_personal_access_token_ssm_parameter = "/path/to/parameter"
```

Store your token in AWS Systems Manager Parameter Store as a `SecureString` type parameter.
You provide the SSM parameter path as input.

The module will retrieve it and use it to create the CodeBuild credential.

[![Parameter Store Configuration Example](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)

> **Security Note:** Credentials will be stored in Terraform state.

#### AWS CodeConnections (GitHub App)
```terraform
github_codeconnection_arn = "arn:aws:codeconnections:region:account-id:connection/id"
```

Provide the ARN of an active GitHub App CodeConnection. The module will create the CodeBuild credential using this connection.

> **Note:** For multi-project deployments, Option B is recommended as it provides better visibility and makes credential management more explicit across your infrastructure.

## Handling Existing Credentials

If a GitHub credential already exists in CodeBuild for your account and region:
- The existing credential is used automatically by all projects, no additional configuration is required
- Attempting to create another CodeBuild credential will produce an error

## Limitations and Considerations

- **One credential per region:** CodeBuild enforces a limit of one GitHub credential per AWS account per region. Attempting to create additional credentials will result in an error.
- **State storage:** When using Terraform (Options B or C), credentials may be stored in state files. Implement appropriate state backend security measures.

## Additional Authentication Methods

### OAuth
OAuth authentication is supported by CodeBuild but is not currently documented in this guide. Refer to the [AWS CodeBuild documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/) for OAuth configuration details.

## Troubleshooting

If you encounter issues:
1. Verify that only one credential exists per account per region
2. Confirm your GitHub token has the required permissions
3. Check that your token hasn't expired
