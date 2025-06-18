resource "aws_ecs_cluster" "medusa-cluster" {
  name = "strapi-deployment-cluster"
  tags = {
    name = "strapi-deployment-cluster"
  }
} 
