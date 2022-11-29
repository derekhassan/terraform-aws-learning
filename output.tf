output "vm_server_instance_id" {
  value = aws_instance.my_ec2.id
}

output "eip_public_ip" {
  value = aws_eip_association.eip_assoc.public_ip
}
