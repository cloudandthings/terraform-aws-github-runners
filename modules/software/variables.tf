variable "software" {
  type        = string
  description = "TODO"

  validation {
    condition = contains([
      "python3", "docker-engine", "terraform", "terraform-docs", "tflint"
    ], var.software)
    error_message = "The software must be one of [\"python3\", \"docker-engine\", \"terraform\", \"terraform-docs\", \"tflint\"]."
  }
}
