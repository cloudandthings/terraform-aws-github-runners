# Packer Security Group Rules Example

This example demonstrates how to add custom security group ingress rules to the default security group created by the module. This is particularly useful when running Packer on CodeBuild, which requires additional ports for WinRM and SSH communicators.

## Usage

The key feature demonstrated here is the `security_group_ingress_rules` variable:

```hcl
security_group_ingress_rules = [
  {
    from_port   = 1024
    to_port     = 65535
    ip_protocol = "tcp"
    cidr_ipv4   = "10.0.0.0/16" # Replace with your VPC CIDR
    description = "Required to run Packer on CodeBuild (WinRM/SSH communicator)"
  }
]
```

## Important Notes

1. The `security_group_ingress_rules` variable only applies when:
   - `vpc_id` is specified
   - `security_group_ids` is empty (allowing the module to create a default security group)

2. If you provide your own `security_group_ids`, you should manage ingress rules on those security groups directly.

3. Replace `10.0.0.0/16` with your actual VPC CIDR block.

## Packer Requirements

When running Packer on CodeBuild, you typically need:
- **WinRM communicator**: Ports 1024-65535 (ephemeral ports)
- **SSH communicator**: Ports 1024-65535 (ephemeral ports)

The security group rule allows traffic on these ports from within your VPC so that Packer can communicate with the instances it creates.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
