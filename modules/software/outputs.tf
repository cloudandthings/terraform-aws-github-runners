output "packages" {
  value       = local.packages_out
  description = "Ordered list of cloudinit packages"
}

output "runcmds" {
  value       = local.runcmds_out
  description = "Ordered list of cloudinit runcmds"
}

output "software_packs" {
  description = "List of software packs that were installed."
  value       = local.software_packs
}
