
output "test_packages" {
  value       = module.test_software[*].packages
  description = "packages"
}

output "test_runcmds" {
  value       = module.test_software[*].runcmds
  description = "runcmds"
}

output "test_default_packages" {
  value       = module.test_software_default.packages
  description = "packages"
}

output "test_order_runcmds" {
  value       = module.test_software_order.runcmds
  description = "runcmds"
}
