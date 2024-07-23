output "vpc_id" {
  value = module.vpc.kcvpc_id
}

output "public_subnet_id" {
  value = aws_subnet.PublicSubnet
}

output "private_subnet_id" {
  value = aws_subnet.PrivateSubnet
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

output "public_nacl_id" {
  value = aws_network_acl.public_nacl.id
}

output "private_nacl_id" {
  value = aws_network_acl.private_nacl.id
}
output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}

output "private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}
