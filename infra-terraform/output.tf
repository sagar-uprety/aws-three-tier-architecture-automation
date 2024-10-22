output "vpc_id" {
  value = module.vpc.vpc_id
  description = "value of the VPC ID"
}

output "alb_dns_name" {
  value = module.alb.dns_name
  description = "value of the DNS name of the ALB"
}

output "autoscaling_group_id" {
  value = module.asg.autoscaling_group_id
  description = "value of the autoscaling group ID"
}

output "launch_template_arn" {
  value = module.asg.launch_template_arn
  description = "value of the launch template ARN"
}

output "target_groups" {
  value = module.alb.target_groups
  description = "value of the target groups"
}

output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
  description = "value of the RDS instance endpoint"
}