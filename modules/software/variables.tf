variable "software" {
  type        = string
  description = "TODO"

  validation {
    condition = contains([
      "python3", "docker_engine", "terraform"
    ], var.software)
    error_message = "The software must be one of [\"python3\", \"docker_engine\", \"terraform\"]."
  }
}
