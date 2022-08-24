locals {
  software = [
    "python3",
    "docker-engine",
    "terraform", "terraform-docs", "tflint"
  ]
}

module "software" {
  source   = "../../../modules/software"
  count    = length(local.software)
  software = local.software[count.index]
}
