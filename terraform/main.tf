provider "aws" {
  region = "eu-north-1"
}

module "netwoking" {
  source = "./netwoking"

  project_name = var.project_name
}

module "compute" {
  source = "./compute"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.netwoking.vpc_id
  public_subnet_ids   = module.netwoking.public_subnet_ids
  private_subnet_ids  = module.netwoking.private_subnet_ids
  instance_type       = var.compute_instance_type
  node_max_size       = var.ecs_max_instances
  service_min_count   = var.ecs_min_tasks
  service_max_count   = var.ecs_max_tasks
  container_image     = var.container_image
  container_image_tag = var.container_image_tag

}
