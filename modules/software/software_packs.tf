locals {
  # All available software packs
  all = [
    # Contains base packages eg curl, zip, etc
    "BASE_PACKAGES",

    "docker-engine",
    "node",
    "pre-commit",
    "python2",
    "python3",
    "terraform",
    "terraform-docs",
    "tflint",
    "tfsec"
  ]
}
