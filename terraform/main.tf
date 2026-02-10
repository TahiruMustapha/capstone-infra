terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_security_group" "app_sg" {
  name_prefix = "capstone-sg-${var.pr_number}-"
  description = "Allow Web and SSH traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Port (Debug)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "capstone-sg-${var.pr_number}"
    Environment = "ephemeral"
    PR          = var.pr_number
    Project     = "devops-training"
  }
}
resource "aws_instance" "capstoneServer" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  security_groups = [aws_security_group.app_sg.name]

  user_data = templatefile("user_data.sh", {
    backend_image      = var.backend_image
    frontend_image     = var.frontend_image
    postgres_user      = var.POSTGRES_USER
    postgres_password  = var.POSTGRES_PASSWORD
    postgres_db        = var.POSTGRES_DB
    init_sql_content   = file("../init.sql")
  })

  tags = {
    Name        = "phoenix-pr-${var.pr_number}"
    Environment = "ephemeral"
    PR          = var.pr_number
    Project     = "devops-training"
  }
}
