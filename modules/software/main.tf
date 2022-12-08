locals {

  packages = {
    "docker-engine" = ["ca-certificates", "curl", "gnupg", "lsb-release"]
    "node"          = ["nodejs"]
    "pre-commit"    = ["pre-commit"]
    "python2"       = ["python2"]
    "python3"       = ["python3", "python3-pip", "python3-venv", "python-is-python3"]
    "tflint"        = ["unzip"]
  }

  runcmds = {
    "docker-engine" = [
      "echo ==== DOCKER-ENGINE ====",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      # "sudo usermod -a -G root ubuntu" # issue #6
    ]

    "terraform" = [
      "echo ==== TERRAFORM ====",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt-get update",
      "sudo apt-get install -y terraform"
    ]

    "terraform-docs" = [
      "echo ==== TERRAFORM-DOCS ====",
      "curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz",
      "tar -xzf terraform-docs.tar.gz",
      "chmod +x terraform-docs",
      "mv terraform-docs /usr/local/bin/terraform-docs"
    ]

    "tflint" = [
      "echo ==== TFLINT ====",
      "sudo curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
    ]

    "tfsec" = [
      "echo ==== TFSEC ====",
      "sudo curl -sSLo ./tfsec.tar.gz https://github.com/aquasecurity/tfsec/releases/download/v1.28.0/tfsec_1.28.0_linux_amd64.tar.gz",
      "tar -xzf tfsec.tar.gz",
      "chmod +x tfsec",
      "mv tfsec /usr/local/bin/tfsec"
    ]

    "__TEST_ORDER__" = [
      "z1", "y2", "x3", "w4", "v5"
    ]
  }

  packages_out = (
    var.software_pack == "ALL"
    ? flatten([for k, v in local.packages : v])
    : lookup(local.packages, var.software_pack, [])
  )
  runcmds_out = (
    var.software_pack == "ALL"
    ? flatten([for k, v in local.runcmds : v])
    : lookup(local.runcmds, var.software_pack, [])
  )

  software_packs = (
    var.software_pack == "ALL"
    ? local.all
    : [var.software_pack]
  )
}
