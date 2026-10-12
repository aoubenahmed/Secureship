output "private1_private_dns" {
  value = aws_instance.private_server1.private_dns
}

output "private2_private_dns" {
  value = aws_instance.private_server2.private_dns
}
