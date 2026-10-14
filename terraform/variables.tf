variable "project_name" {
  description = "SecureShip resource name prefix."
  type        = string
  default     = "secureship"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "compute_instance_type" {
  description = "x86 ECS node instance type."
  type        = string
  default     = "t3.micro"
}

variable "ecs_max_instances" {
  description = "Maximum ECS nodes; default fits the project's 8-vCPU quota alongside networking instances."
  type        = number
  default     = 1
}

variable "ecs_min_tasks" {
  description = "Initial and minimum ECS tasks; set to 1 after pushing the application image."
  type        = number
  default     = 0
}

variable "ecs_max_tasks" {
  description = "Maximum ECS tasks."
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Optional application image override; null uses the SecureShip ECR repository."
  type        = string
  default     = null
}

variable "container_image_tag" {
  description = "Application image tag in the SecureShip ECR repository."
  type        = string
  default     = "latest"
}
