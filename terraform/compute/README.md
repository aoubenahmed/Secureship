# SecureShip Compute

This module provisions an ECS-on-EC2 cluster, the `secureship-app` ECR
repository, application IAM roles, CloudWatch logs, and an HTTP application
load balancer. The root module supplies the VPC and subnet IDs from `netwoking`.
The load balancer uses both public subnets; ECS nodes and tasks use private
subnets, with application ingress restricted to the load balancer.

The defaults target the existing Stockholm deployment:

- Resource prefix: `secureship-dev`.
- ECS-optimized Amazon Linux 2023 with `t3.micro` nodes.
- Zero initial ECS nodes and application tasks; maximum one node and one task.
- Task allocation: 256 CPU units and 256 MiB of memory; HTTP port 80.
- Logs use the AWS provider region and retain events for 14 days.
- The image defaults to the project ECR repository with immutable tags.

One ECS node adds two vCPUs to the two private servers and single NAT instance,
for a maximum of eight vCPUs with the current project instance types. Increase
capacity limits only after accounting for the regional quota and task ENI limits.
The single-node deployment stops the old task before starting its replacement.

## Bootstrap

Run Terraform from the parent `terraform` directory to provision the repository
and service with zero tasks. After pushing your application image, persist its
tag and enable the service in a root variable file, for example:

```hcl
container_image_tag = "v1"
ecs_min_tasks       = 1
```

Use a new tag for each release because repository tags are immutable. The
application must listen on port 80 and answer the `/` health check by default;
the compute module exposes `container_port` and `health_check_path` to customize
these settings. `container_image` can override the project repository reference.

Root outputs expose `ecr_repository_url`, `ecs_cluster_name`,
`ecs_service_name`, and `alb_url`. The load balancer has no healthy application
targets while the service has zero tasks.

## Verification

```sh
terraform validate
terraform test -filter=tests/compute.tftest.hcl
```

The tests require Terraform 1.7 or later and use a mocked AWS provider; they do
not create cloud resources.
