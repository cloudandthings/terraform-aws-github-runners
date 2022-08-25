output "aws_autoscaling_group_arn" {
  description = "TODO"
  value       = aws_autoscaling_group.this.arn
}

output "aws_security_group_id" {
  description = "TODO"
  value       = aws_security_group.this.id
}

output "aws_launch_template_arn" {
  description = "TODO"
  value       = aws_launch_template.this.arn
}
