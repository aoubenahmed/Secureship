output "private1_private_dns" {
  value = module.netwoking.private1_private_dns
}

output "private2_private_dns" {
  value = module.netwoking.private2_private_dns
}

output "ecs_cluster_name" {
  value = module.compute.cluster_name
}

output "ecs_service_name" {
  value = module.compute.service_name
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "alb_url" {
  value = module.compute.alb_url
}
