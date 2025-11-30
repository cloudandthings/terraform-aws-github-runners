# Setting Up Authentication to GitHub

## Overview

This guide covers the configuration of GitHub authentication for AWS CodeBuild projects. CodeBuild supports multiple authentication methods including personal access tokens, OAuth, and GitHub App connections.

> **⚠️ Critical Limitation:** AWS CodeBuild allows only ONE GitHub credential per AWS account per region. This credential is automatically shared across all CodeBuild projects within that account and region. You can override this shared credential for specific projects if needed.

## Prerequisites

Before proceeding, ensure you understand:

- **Single credential limitation**: AWS CodeBuild enforces one GitHub credential per AWS account per region. This "baseline credential" is automatically used by all CodeBuild projects in that account and region.
- **Override capability**: Individual projects can override the baseline credential if you need project-specific authentication.
- **Multiple authentication methods**: CodeBuild supports Personal Access Tokens, OAuth, and GitHub App connections (via AWS CodeConnections).
- **State storage implications**: Some configuration methods store credentials in Terraform state files, requiring proper security measures.

## Choosing Your Approach

Use this table to select the best option for your needs:

| Scenario | Recommended Option | Why |
|----------|-------------------|-----|
| Quick setup without IaC | Manual Console/CLI (2A) | Fast, no state management |
| IaC with centralized control | Terraform Resource (2B) | Explicit, visible across infrastructure |
| Module manages everything | Module Variables (2C) | Simplified, consolidates configuration |
| Project-specific credentials | Override Mechanism (Step 3) | Isolates credentials per project |
| Enhanced security/compliance | OAuth (see Authentication Methods) | Automatic token refresh, better audit trail |

## Step 1: Obtain GitHub Credentials

Choose one of the following authentication methods:

### Personal Access Token (Most Common)

1. Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) through the GitHub console
2. Ensure your token has the [required permissions](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html#access-tokens-github-prereqs):
   - `repo` - Full control of private repositories
   - `admin:repo_hook` - Full control of repository hooks

**When to use:**
- Standard use cases
- Simple setup requirements
- Individual or small team projects

### OAuth Token

OAuth provides enhanced security with automatic token refresh capabilities.

1. Obtain an OAuth token through GitHub's OAuth flow
2. Store in AWS Secrets Manager with this JSON structure:
   ```json
   {
     "ServerType": "GITHUB",
     "AuthType": "OAUTH",
     "Token": "gho_YourOAuthTokenValue"
   }
   ```

**When to use:**
- Long-lived authentication without manual token rotation
- Organization-wide authentication
- Enhanced security compliance requirements

### GitHub App Connection (AWS CodeConnections)

Create a GitHub App connection through AWS CodeConnections (formerly AWS CodeStar Connections).

**When to use:**
- Enterprise GitHub configurations
- Fine-grained repository access control
- Integration with AWS security controls

Refer to the [AWS CodeConnections documentation](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-create-github.html) for setup instructions.

## Step 2: Create the Baseline GitHub Credential

The baseline credential is shared across all CodeBuild projects in your AWS account and region by default. Choose one of the following methods to create it:

### Option A: Manual Configuration via AWS Console or CLI

**Recommended for:** Quick setup without infrastructure-as-code dependencies.

Follow the [AWS documentation](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-create-github.html) to add the credential through the AWS Console or CLI.

**AWS CLI example:**
```bash
aws codebuild import-source-credentials \
  --server-type GITHUB \
  --auth-type PERSONAL_ACCESS_TOKEN \
  --token your-github-token
```

**Pros:**
- Quick setup
- No Terraform state concerns
- Credentials not stored in code

**Cons:**
- Manual process
- Not tracked in version control
- Requires AWS Console/CLI access

### Option B: Terraform Resource

**Recommended for:** Infrastructure-as-code with centralized credential management.

Define an [`aws_codebuild_source_credential`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) resource in your Terraform configuration.

**Using AWS Secrets Manager (Recommended):**
```hcl
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "SECRETS_MANAGER"
  server_type = "GITHUB"
  token       = "arn:aws:secretsmanager:region:account-id:secret:name"
}
```

**Using Personal Access Token directly:**
```hcl
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}
```

> **⚠️ Security Note:** Direct token values are stored in Terraform state. Ensure your state backend uses encryption at rest, access controls, and audit logging. The Secrets Manager approach is preferred as it only stores the ARN in state.

**Pros:**
- Infrastructure-as-code approach
- Visible across your infrastructure
- Version controlled configuration

**Cons:**
- Credentials may be in Terraform state (depending on auth_type)
- Requires Terraform expertise

> **💡 Multi-project Tip:** For deployments with multiple projects, Option B is recommended as it provides better visibility and makes credential management explicit across your infrastructure.

### Option C: Via This Module

**Recommended for:** Simplified setup when using this module for all GitHub runner infrastructure.

This module can create the CodeBuild source credential on your behalf. Choose one of the following input variables:

#### C1: AWS Secrets Manager
```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  github_secretsmanager_secret_arn = "arn:aws:secretsmanager:region:account-id:secret:name"

  # Other configuration...
}
```

The module passes the secret ARN to CodeBuild. The secret value itself is not read by the module.

**State Storage:** Only the ARN is stored in state.

#### C2: Direct Token Value
```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  github_personal_access_token = var.github_token

  # Other configuration...
}
```

Provide the token value as a variable input.

**State Storage:** Token is stored in Terraform state.

#### C3: AWS Systems Manager Parameter Store
```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  github_personal_access_token_ssm_parameter = "/path/to/parameter"

  # Other configuration...
}
```

Store your token in AWS Systems Manager Parameter Store as a `SecureString` type parameter. The module retrieves it and uses it to create the CodeBuild credential.

![Parameter Store Configuration Example](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)

**State Storage:** Token is stored in Terraform state after retrieval.

#### C4: AWS CodeConnections (GitHub App)
```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  github_codeconnection_arn = "arn:aws:codeconnections:region:account-id:connection/id"

  # Other configuration...
}
```

Provide the ARN of an active GitHub App CodeConnection.

**State Storage:** Only the ARN is stored in state.

> **⚠️ Security Note:** Options C2 and C3 store the token value in Terraform state. Options C1 and C4 only store ARNs. Ensure your state backend uses encryption at rest, access controls, and audit logging.

**Pros:**
- Consolidated configuration
- Simplified module usage
- Multiple credential source options

**Cons:**
- Increases module coupling
- Less visible in multi-module deployments
- Some options store credentials in state

## Step 3: Overriding Credentials for Specific Projects

If a baseline CodeBuild credential already exists, all projects use it automatically. Attempting to create another credential for the same account/region/service will produce an error.

To use different credentials for a specific project, override the baseline credential:

```hcl
module "github_runner" {
  source = "cloudandthings/github-runners/aws"

  # Your configuration here
  # ...

  # Override the baseline CodeBuild credential
  source_auth = {
    type     = "SECRETS_MANAGER"
    resource = "arn:aws:secretsmanager:region:account:secret:name"
  }
}
```

**Supported override types:**
- `SECRETS_MANAGER` - ARN of a Secrets Manager secret
- `OAUTH` - OAuth token for GitHub
- `CODECONNECTIONS` - GitHub App connection ARN

**When to use overrides:**
- Different repositories require different access levels
- Separating credentials for security or compliance
- Testing with different authentication methods
- Isolating credentials between environments

## Step 4: Verify Your Configuration

After setting up credentials, verify the configuration is correct:

### Via AWS CLI
```bash
aws codebuild list-source-credentials
```

### Expected Output
```json
{
  "sourceCredentialsInfos": [
    {
      "arn": "arn:aws:codebuild:region:account:token/github",
      "serverType": "GITHUB",
      "authType": "PERSONAL_ACCESS_TOKEN"
    }
  ]
}
```

### Via Terraform
```bash
terraform state show aws_codebuild_source_credential.github
```

## Troubleshooting

### Error: "Source credential already exists"

**Cause:** A credential already exists for GitHub in this account and region.

**Solutions:**
1. Use the existing credential (it's shared automatically)
2. Delete the existing credential and create a new one:
   ```bash
   aws codebuild delete-source-credentials --arn <credential-arn>
   ```
3. Override the credential for your specific project (see Step 3)

### Authentication Failures During Builds

**Possible causes and solutions:**

1. **Token expired**
   - Generate a new token with the same permissions
   - Update the credential with the new token

2. **Insufficient permissions**
   - Verify token has required scopes: `repo`, `admin:repo_hook`
   - Check [AWS documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html#access-tokens-github-prereqs) for complete requirements

3. **Repository access not granted**
   - Ensure the token owner has access to the repository
   - For organization repos, verify the token has organization access

4. **Secret not accessible**
   - If using Secrets Manager, verify CodeBuild has permission to read the secret
   - Check IAM policies allow `secretsmanager:GetSecretValue`

### Error: "No valid credential found"

**Cause:** No credential exists and none is configured.

**Solution:** Complete Step 2 to create a baseline credential.

## Credential Rotation

To rotate credentials without downtime:

### For Secrets Manager / SSM Parameter Store
1. Update the secret/parameter value in AWS
2. No Terraform changes needed
3. New builds will use the updated credential automatically

### For Direct Token Values
1. Update your Terraform variable
2. Run `terraform apply`
3. Coordinate timing to minimize authentication failures

### Best Practice
Use Secrets Manager (Option B or C1) or CodeConnections (C4) for easiest rotation.

## Security Best Practices

1. **Use Secrets Manager or CodeConnections** when possible to avoid storing tokens in Terraform state
2. **Enable state encryption** if using direct token values
3. **Implement least-privilege access** - grant only required repository permissions
4. **Rotate credentials regularly** - especially personal access tokens
5. **Use separate credentials per environment** when possible using the override mechanism
6. **Audit credential usage** - monitor CloudTrail logs for CodeBuild authentication events
7. **Consider OAuth or GitHub Apps** for enhanced security in production environments

## Limitations and Considerations

- **One credential per region:** CodeBuild enforces a strict limit of one GitHub credential per AWS account per region for each service type (GitHub, Bitbucket, etc.)
- **Shared by default:** All CodeBuild projects in the same account/region use the baseline credential unless overridden
- **State storage:** Terraform-based approaches (Options B and C) may store credentials in state files depending on the authentication method chosen
- **No automatic rotation:** Personal access tokens require manual rotation. Consider OAuth or GitHub Apps for auto-refresh capabilities
- **Account-level impact:** Deleting the baseline credential affects all projects using it simultaneously

## Next Steps

- **Deploy your first runner:** Continue with the main module documentation
- **Configure webhooks:** Set up GitHub webhooks for automatic build triggers
- **Review AWS CodeBuild limits:** Check [service quotas](https://docs.aws.amazon.com/codebuild/latest/userguide/limits.html) for your account
- **Set up monitoring:** Configure CloudWatch alarms for build failures and authentication errors
- **Explore advanced configurations:** Review the module's complete variable reference

## Additional Resources

- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [AWS CodeConnections](https://docs.aws.amazon.com/dtconsole/latest/userguide/welcome-connections.html)
- [Terraform AWS Provider - CodeBuild Source Credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential)

## Contributing

Found an issue or have suggestions? Contributions to this documentation are welcome! Please submit a pull request or open an issue in the repository.
