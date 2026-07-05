output "alb_dns_name" {
  description = "Public DNS name of the load balancer — hit this to reach the app"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "Push images here from CI"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "sns_alerts_topic_arn" {
  description = "Subscribe additional endpoints (e.g. a Slack webhook via Chatbot) here"
  value       = aws_sns_topic.alerts.arn
}
