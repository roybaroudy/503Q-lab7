output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "External ALB DNS name"
  value       = aws_lb.external.dns_name
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = aws_instance.bastion.public_ip
}

output "ssm_parameter_paths" {
  description = "SSM parameter paths"
  value = [
    aws_ssm_parameter.db_password.name,
    aws_ssm_parameter.app_env.name
  ]
}