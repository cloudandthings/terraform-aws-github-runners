locals {
  packages_python3 = ["python3", "python-is-python3", "python3-pip", "python3-venv"]

  packages_docker_engine = ["ca-certificates", "curl", "gnupg", "lsb-release"]

  runcmds_docker_engine = [
    "echo **** DOCKER ENGINE ****",
    "sudo mkdir -p /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
    "sudo usermod -aG docker ubuntu"
  ]

  runcmds_terraform = [
    "echo **** TERRAFORM ****",
    "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
    "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
    "sudo apt-get update",
    "sudo apt-get install -y terraform"
  ]

}
