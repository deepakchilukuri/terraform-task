output "ec2_public_ip" {
  value = aws_instance.deepak_ec2.public_ip
}

output "private_key_path" {
  value = local_file.private_key.filename
}

output "vpc_id" {
  value = aws_vpc.deepak_vpc.id
}

output "subnet_id" {
  value = aws_subnet.deepak_public_subnet.id
}
