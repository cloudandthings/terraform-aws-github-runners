output "packages" {
  value       = toset(local.packages_out)
  description = "TODO"
}

output "runcmds" {
  value       = toset(local.runcmds_out)
  description = "TODO"
}
