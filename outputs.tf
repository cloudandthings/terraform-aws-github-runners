/*
output "aws_autoscaling_group_arn" {
  description = "The Auto Scaling Group ARN."
  value       = flatten(aws_autoscaling_group.this[*].arn)
}

output "security_groups" {
  description = "The Security Groups associated with EC2 instances."
  value       = local.security_groups
}

output "aws_launch_template_arn" {
  description = "The EC2 launch template."
  value       = aws_launch_template.this.arn
}
*/

output "software_packs" {
  description = "List of software packs that were installed."
  value       = flatten(module.software_packs[*].software_packs)
}

output "aws_instance_id" {
  description = "Instance ID (when `scaled_mode=single-instance`)"
  value       = concat([for x in aws_instance.this : x.id], [""])[0]
}

output "aws_instance_public_ip" {
  description = "Instance public IP (when `scaled_mode=single-instance`)"
  value       = concat([for x in aws_instance.this : x.public_ip], [""])[0]
}
