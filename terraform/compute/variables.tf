variable "project_name" {
  description = "Project prefix for compute resources."
  type        = string
  default     = "secureship"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,15}$", var.project_name))
    error_message = "project_name must be a lowercase identifier of at most 16 characters."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,7}$", var.environment))
    error_message = "environment must be a lowercase identifier of at most 8 characters."
  }
}

variable "vpc_id" {
  description = "VPC provided by the networking module."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the application load balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The load balancer requires at least two public subnets."
  }
}

variable "private_subnet_ids" {
  description = "Private subnets for ECS nodes and tasks."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "At least one private subnet is required."
  }
}

variable "instance_type" {
  description = "x86 EC2 instance type for ECS container instances."
  type        = string
  default     = "t3.micro"
}

variable "node_min_size" {
  description = "Minimum ECS node count; zero avoids launching nodes before the image is ready."
  type        = number
  default     = 0

  validation {
    condition     = var.node_min_size >= 0 && floor(var.node_min_size) == var.node_min_size
    error_message = "node_min_size must be a nonnegative integer."
  }
}

variable "node_max_size" {
  description = "Maximum ECS nodes; one t3.micro leaves the project within its 8-vCPU budget."
  type        = number
  default     = 1

  validation {
    condition     = var.node_max_size >= 1 && floor(var.node_max_size) == var.node_max_size
    error_message = "node_max_size must be a positive integer."
  }
}

variable "service_min_count" {
  description = "Minimum and initial application task count; raise after pushing the image."
  type        = number
  default     = 0

  validation {
    condition     = var.service_min_count >= 0 && floor(var.service_min_count) == var.service_min_count
    error_message = "service_min_count must be a nonnegative integer."
  }
}

variable "service_max_count" {
  description = "Maximum application task count; one task fits the default micro node ENI capacity."
  type        = number
  default     = 1

  validation {
    condition     = var.service_max_count >= 1 && floor(var.service_max_count) == var.service_max_count
    error_message = "service_max_count must be a positive integer."
  }
}

variable "container_image" {
  description = "Optional image override; defaults to the SecureShip ECR repository."
  type        = string
  default     = null

  validation {
    condition     = var.container_image == null ? true : length(trimspace(var.container_image)) > 0
    error_message = "container_image must be null or a nonempty image reference."
  }
}

variable "container_image_tag" {
  description = "Immutable ECR image tag to deploy."
  type        = string
  default     = "latest"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$", var.container_image_tag))
    error_message = "container_image_tag must be a valid container image tag."
  }
}

variable "container_port" {
  description = "Application HTTP port."
  type        = number
  default     = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535 && floor(var.container_port) == var.container_port
    error_message = "container_port must be an integer from 1 to 65535."
  }
}

variable "task_cpu" {
  description = "ECS task CPU units; 1024 units equals one vCPU."
  type        = number
  default     = 256

  validation {
    condition     = var.task_cpu > 0 && floor(var.task_cpu) == var.task_cpu
    error_message = "task_cpu must be a positive integer."
  }
}

variable "task_memory" {
  description = "ECS task memory in MiB."
  type        = number
  default     = 256

  validation {
    condition     = var.task_memory > 0 && floor(var.task_memory) == var.task_memory
    error_message = "task_memory must be a positive integer."
  }
}

variable "container_environment" {
  description = "Non-secret application environment variables."
  type        = map(string)
  default     = {}
}

variable "health_check_path" {
  description = "Application load balancer health check path."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/", var.health_check_path))
    error_message = "health_check_path must start with a slash."
  }
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDRs allowed to access the public HTTP listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allowed_http_cidrs) > 0 && alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "allowed_http_cidrs must contain valid IPv4 CIDRs."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a supported CloudWatch retention period."
  }
}

variable "tags" {
  description = "Additional compute resource tags."
  type        = map(string)
  default     = {}
}
