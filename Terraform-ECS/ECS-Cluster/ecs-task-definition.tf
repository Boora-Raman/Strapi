resource "aws_ecs_task_definition" "TD" {
  family                   = "strapi-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "medusa"
      image = "booraraman/strapi-app:d8c1479b8fc172b9d2969fbf364c5255c513fb33"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/strapi-service"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "medusa"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}
