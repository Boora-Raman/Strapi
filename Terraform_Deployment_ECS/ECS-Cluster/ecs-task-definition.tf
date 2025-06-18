resource "aws_ecs_task_definition" "TD" {
  family                   = "medusa-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "medusa"
      image = "booraraman/medusa:67abb80f3c2a083b837f5257534cf9b112004fe5"
      essential = true
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/medusa-service"
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
