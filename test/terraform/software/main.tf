locals {
  software = ["python3", "docker_engine", "terraform"]
}

module "software" {
  source   = "../../../modules/software"
  count    = length(local.software)
  software = local.software[count.index]
}
