
output "test_packages" {
  value       = module.test_software[*].packages
  description = "packages"
}

output "test_runcmds" {
  value       = module.test_software[*].runcmds
  description = "runcmds"
}

output "test_all_packages" {
  value       = module.test_software_all.packages
  description = "packages"
}

output "test_all_software_packs" {
  value       = module.test_software_all.software_packs
  description = "software_packs"
}

output "test_order_runcmds" {
  value       = module.test_software_order.runcmds
  description = "runcmds"
}
