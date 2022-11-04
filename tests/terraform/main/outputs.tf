output "public_ip" {
  description = "public_ip"
  value       = module.this.aws_instance_public_ip
}

output "instance_id" {
  description = "instance_id"
  value       = module.this.aws_instance_id
}

output "public_key" {
  description = "public_key"
  value       = var.public_key
}

output "software_packs" {
  description = "software_packs"
  value       = module.this.software_packs
}
