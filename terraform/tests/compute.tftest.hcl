mock_provider "aws" {
  mock_data "aws_region" {
    defaults = { name = "eu-north-1" }
  }

  mock_data "aws_partition" {
    defaults = { partition = "aws" }
  }

  mock_data "aws_ssm_parameter" {
    defaults = { value = "ami-0123456789abcdef0" }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect    = "Allow"
          Action    = "sts:AssumeRole"
          Principal = { Service = "ec2.amazonaws.com" }
        }]
      })
    }
  }
}

variables {
  vpc_id             = "vpc-0123456789abcdef0"
  public_subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  private_subnet_ids = ["subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
}

run "bootstrap_defaults" {
  command = plan

  module {
    source = "./compute"
  }

  assert {
    condition     = aws_ecs_service.app.desired_count == 0 && aws_autoscaling_group.ecs.desired_capacity == 0
    error_message = "The initial deployment must not start nodes or tasks before an image is pushed."
  }

  assert {
    condition     = aws_launch_template.ecs_ec2.instance_type == "t3.micro" && aws_autoscaling_group.ecs.max_size == 1 && aws_appautoscaling_target.ecs_target.max_capacity == 1
    error_message = "Default compute capacity must fit the project's remaining micro-instance budget."
  }

  assert {
    condition     = sort(tolist(aws_autoscaling_group.ecs.vpc_zone_identifier)) == sort(var.private_subnet_ids) && sort(tolist(aws_ecs_service.app.network_configuration[0].subnets)) == sort(var.private_subnet_ids)
    error_message = "Both ECS hosts and tasks must use the supplied private subnets."
  }

  assert {
    condition     = sort(tolist(aws_lb.main.subnets)) == sort(var.public_subnet_ids)
    error_message = "The public load balancer must use the supplied public subnets."
  }

  assert {
    condition     = aws_ecs_cluster.main.name == "secureship-dev-cluster" && aws_ecr_repository.app.name == "secureship-app" && aws_ecr_repository.app.image_tag_mutability == "IMMUTABLE"
    error_message = "Resource names and immutable image tags must match SecureShip."
  }

  assert {
    condition     = tolist(aws_security_group.ecs_task.ingress)[0].from_port == 80 && length(coalesce(tolist(aws_security_group.ecs_task.ingress)[0].cidr_blocks, toset([]))) == 0
    error_message = "Application ingress must use the HTTP port without opening a VPC-wide CIDR rule."
  }
}

run "application_settings" {
  command = plan

  module {
    source = "./compute"
  }

  variables {
    environment           = "staging"
    container_image       = "example.invalid/secureship:test"
    container_port        = 8080
    container_environment = { APP_MODE = "test" }
    service_min_count     = 1
  }

  assert {
    condition     = aws_ecs_cluster.main.name == "secureship-staging-cluster" && aws_ecs_service.app.desired_count == 1
    error_message = "Environment and initial task count must be configurable."
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.app.container_definitions)[0].image == var.container_image && jsondecode(aws_ecs_task_definition.app.container_definitions)[0].logConfiguration.options["awslogs-region"] == "eu-north-1"
    error_message = "The application image override and provider region must reach the task definition."
  }

  assert {
    condition     = aws_lb_target_group.app.port == 8080 && tolist(aws_security_group.ecs_task.ingress)[0].to_port == 8080
    error_message = "The configured application port must match the load balancer and task security group."
  }
}

run "reject_invalid_node_bounds" {
  command = plan

  module {
    source = "./compute"
  }

  variables {
    node_min_size = 2
    node_max_size = 1
  }

  expect_failures = [aws_autoscaling_group.ecs]
}

run "reject_invalid_task_bounds" {
  command = plan

  module {
    source = "./compute"
  }

  variables {
    service_min_count = 2
    service_max_count = 1
  }

  expect_failures = [aws_appautoscaling_target.ecs_target]
}
