output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_service_sg_id" {
  description = "The security group ID for the ECS service"
  value       = aws_security_group.ecs_service_sg.id
}
