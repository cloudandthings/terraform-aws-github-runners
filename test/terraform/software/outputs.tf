
output "packages" {
  value       = module.software[*].packages
  description = "packages"
}

output "runcmds" {
  value       = module.software[*].runcmds
  description = "runcmds"
}

output "packages_test" {
  value       = module.software_test.packages
  description = "packages"
}

output "runcmds_test" {
  value       = module.software_test.runcmds
  description = "runcmds"
}
