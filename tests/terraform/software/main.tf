module "test_software_all" {
  source        = "../../../modules/software"
  software_pack = "ALL"
}

module "test_software_order" {
  source        = "../../../modules/software"
  software_pack = "__TEST_ORDER__"
}

module "test_software" {
  source        = "../../../modules/software"
  count         = length(local.software)
  software_pack = local.software[count.index]
}
