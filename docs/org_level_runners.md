# Organization Level Runners

To set up the codebuild runners at the GitHub organization level, use the `source_location` and `source_organization` module inputs like the following:

```hcl
module "github_runner" {
  ...
  source_location = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
  source_organization = "your-org-name"
  ...
}
```
