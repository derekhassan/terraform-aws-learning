output "vm_server_instance_id" {
  value = aws_instance.my_ec2.id
}
output "vm_server_instance_public_dns" {
  value = aws_instance.my_ec2.public_dns
}
output "vm_server_instance_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
output "vm_server_instance_private_ip" {
  value = aws_instance.my_ec2.private_ip
}
