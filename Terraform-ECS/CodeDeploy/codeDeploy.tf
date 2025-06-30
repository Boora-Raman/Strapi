resource "aws_codedeploy_app" "ecs_app" {
  name = "ecs-codedeploy-app"
  compute_platform = "ECS"

}
