# Setting up authentication to GitHub

## 1. Decide on how to authenticate to GitHub

Here we focus on setting up a personal access token to authenticate to GitHub.
OAuth is also supported but not implemented / documented here.

<!-- TODO OAuth -->

### GitHub access token

Note that CodeBuild only supports 1 GitHub token to be configured for all CodeBuild projects in the same AWS Account and Region.

Therefore, when using multiple CodeBuild projects, you can configure the token once per region (not once per project).

There are a few approaches that you could take, choose one from the below.

#### 2. Create your GitHub token

Create a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
Make sure that the fine grained token has [these](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html#access-tokens-github-prereqs) permissions.


#### 2a. Add the token to CodeBuild separately.

You would add the token as [documented here](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html)
This is recommended if you do not want to maintain the token in Terraform.

#### 2b. Provide the token as an input Terraform variable

Note that although the variable is sensitive, the value will still be stored in Terraform state.

#### 2c. Use AWS Parameter Store

<!-- TODO there seems to be a SecretsManager option in the link above - worth investigating -->

Add the token to AWS Systems Manager Parameter Store, and configure this module to read it.
The module will add the token to Codebuild for you.

This is recommended if you have only a single project.

### Adding your token to Parameter Store (Optional)

Add it to AWS Systems Manager Parameter Store with the `SecureString` type.

[![Parameter Store configuration](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png)](https://github.com/cloudandthings/terraform-aws-github-runners/blob/main/docs/images/ssm.png )
