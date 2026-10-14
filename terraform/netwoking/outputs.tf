output "private1_private_dns" {
  value = aws_instance.private_server1.private_dns
}

output "private2_private_dns" {
  value = aws_instance.private_server2.private_dns
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets

  depends_on = [module.vpc]
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets

  depends_on = [module.vpc, module.nat, aws_eip.nat]
}
