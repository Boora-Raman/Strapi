output "cluster-name" {
    value= aws_ecs_cluster.medusa-cluster.name 
}

output "service-name" {
  value = aws_ecs_service.medusa-cluster-service.name
}