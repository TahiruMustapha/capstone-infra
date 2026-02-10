variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 24.04"
  default     = "ami-0b6c6ebed2801a5cb" 
}
variable "POSTGRES_USER" {
  description = "Postgres USER"
  type = string
  sensitive = true
}

variable "POSTGRES_PASSWORD" {
  description = "Postgres Password"
  type = string
  sensitive = true
}
variable "POSTGRES_DB" {
  description = "Postgres DB "
  type = string
  sensitive = true
}
variable "key_name" {
  description = "Name of the SSH key pair to use for the instance"
  type        = string
  default = "capstone-key"

}

variable "pr_number" {
  description = "Pull Request Number for tagging"
  type        = string
  default     = "0"
}

variable "backend_image" {
  description = "Docker image for Backend"
  type        = string
  default     = "mustaphatahiru/capstone-backend:v2"
}

variable "frontend_image" {
  description = "Docker image for Frontend"
  type        = string
  default     = "mustaphatahiru/capstone-frontend:latest"
}
