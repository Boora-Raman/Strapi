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

