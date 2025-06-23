resource "aws_ecs_cluster" "medusa-cluster" {
  name = "strapi-deployment-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    name = "Strapi-Deployment-ECS-workspace"
  }
}

resource "aws_ecs_cluster_capacity_providers" "strapi-cluster-capacity" {
  cluster_name = aws_ecs_cluster.medusa-cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}
