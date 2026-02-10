terraform {
  backend "s3" {
    bucket         = "capstone-terraform-state-b"
    key            = "replace me"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "capstone-terraform-locks"
  }
}
