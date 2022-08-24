
output "packages" {
  value       = module.software[*].packages
  description = "packages"
}

output "runcmds" {
  value       = module.software[*].runcmds
  description = "runcmds"
}
