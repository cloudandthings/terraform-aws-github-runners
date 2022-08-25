locals {
  software = [
    "python3",
    "docker-engine",
    "terraform", "terraform-docs", "tflint"
  ]
}

module "software" {
  source        = "../../../modules/software"
  count         = length(local.software)
  software_pack = local.software[count.index]
}

module "software_test" {
  source        = "../../../modules/software"
  software_pack = "__TEST__"
}
