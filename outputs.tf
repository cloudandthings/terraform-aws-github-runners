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
