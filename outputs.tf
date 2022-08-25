output "aws_autoscaling_group_arn" {
  description = "The Auto Scaling Group ARN."
  value       = aws_autoscaling_group.this.arn
}

output "aws_security_group_id" {
  description = "The Security Group ID associated with EC2 instances."
  value       = aws_security_group.this.id
}

output "aws_launch_template_arn" {
  description = "The EC2 launch template."
  value       = aws_launch_template.this.arn
}
