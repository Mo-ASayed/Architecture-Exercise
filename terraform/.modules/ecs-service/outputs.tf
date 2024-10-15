output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.service.id
}
