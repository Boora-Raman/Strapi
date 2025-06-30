resource "aws_lb" "test" {
  name               = "strapi-test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_id
  subnets            = var.subnet_ids
  tags = {
    Environment = "production"
  }
}

variable "lb_target_group_name" { default = "strapi-ecs-tg" }

locals {
  target_groups = ["blue", "green"]
}

resource "aws_lb_target_group" "TG" {
  
   count       = length(local.target_groups)
  name        = "${var.lb_target_group_name}-${local.target_groups[count.index]}"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  deregistration_delay = "300"

  health_check {
    path                = "/admin"  # Verify path
    protocol            = "HTTP"
    port = "1337"
    timeout             = 110
    interval            = 115
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG[0].arn
    # target_group_arn = aws_lb_target_group.TG.arn
  }
}

