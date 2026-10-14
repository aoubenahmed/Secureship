output "cluster_name" {
  description = "SecureShip ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "SecureShip application ECS service name."
  value       = aws_ecs_service.app.name
}

output "ecr_repository_url" {
  description = "ECR repository to push application images to."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_url" {
  description = "Public application HTTP endpoint."
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_autoscaling_group_name" {
  description = "Auto Scaling group for ECS container instances."
  value       = aws_autoscaling_group.ecs.name
}
