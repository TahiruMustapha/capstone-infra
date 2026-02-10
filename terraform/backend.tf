
terraform {
  backend "s3" {
    bucket         = "capstone-terraform-state-b"
    key            = "capstone/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "capstone-terraform-locks"
  }
}
