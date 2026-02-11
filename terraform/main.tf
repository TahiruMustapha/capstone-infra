terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

# --- Security Group ---
resource "aws_security_group" "app_sg" {
  # Named with 'phoenix' prefix
  name_prefix = "phoenix-sg-${terraform.workspace}-"
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
    Name        = "phoenix-sg-${terraform.workspace}"
    Environment = var.environment
    PR          = var.pr_number
    Project     = "devops-training"
  }
}

# --- Elastic IP (Production Only) ---
resource "aws_eip" "prod_eip" {
  count    = terraform.workspace == "prod" ? 1 : 0
  vpc      = true

  tags = {
    Name        = "phoenix-eip-${terraform.workspace}"
    Environment = var.environment
  }
}

resource "aws_eip_association" "eip_assoc" {
  count         = terraform.workspace == "prod" ? 1 : 0
  instance_id   = aws_instance.capstoneServer.id
  allocation_id = aws_eip.prod_eip[0].id
}

# --- EC2 Instance ---
resource "aws_instance" "capstoneServer" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = [aws_security_group.app_sg.name]

  user_data = templatefile("user_data.sh", {
    backend_image     = var.backend_image
    frontend_image    = var.frontend_image
    postgres_user     = var.POSTGRES_USER
    postgres_password = var.POSTGRES_PASSWORD
    postgres_db       = var.POSTGRES_DB
    init_sql_content  = file("../init.sql")
  })

  tags = {
    # Named with 'phoenix' prefix
    Name          = "phoenix-server-${terraform.workspace}"
    Environment   = var.environment
    PR            = var.pr_number
    Project       = "devops-training"
    DeploymentId  = var.deployment_id
  }
}
