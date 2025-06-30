resource "aws_codedeploy_deployment_group" "ecs_deploy_group" {
  app_name               = aws_codedeploy_app.ecs_app.name
  deployment_group_name  = "ecs-bluegreen-group"
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }


    deployment_ready_option {
      action_on_timeout   = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }


  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = var.cluster-name
    service_name = var.service-name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener-arns]
      }

      target_group {
        name = var.blue-target_group_arn # blue
      }

      target_group {
        name = var.green-target_group_arn
      }
    }
  }

}



