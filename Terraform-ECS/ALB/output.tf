output "blue-target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.TG[0].arn
}

output "green-target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.TG[1].arn
}
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.test.dns_name
}

output "listener-arns" {
  value = aws_lb_listener.Listener.arn
}
