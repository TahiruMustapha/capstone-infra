output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = terraform.workspace == "prod" ? aws_eip.prod_eip[0].public_ip : aws_instance.capstoneServer.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${terraform.workspace == "prod" ? aws_eip.prod_eip[0].public_ip : aws_instance.capstoneServer.public_ip}"
}
