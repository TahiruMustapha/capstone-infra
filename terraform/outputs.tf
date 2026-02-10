output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.capstoneServer.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.capstoneServer.public_ip}"
}
