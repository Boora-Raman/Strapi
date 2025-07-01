resource "aws_ecs_task_definition" "TD" {
  family                   = "strapi-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "strapi"
      image = "booraraman/strapi-app:053a8235e0799766123b09e5043afbbd48374d65"
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
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "strapi"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}

