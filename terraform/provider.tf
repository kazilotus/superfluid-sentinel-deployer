terraform {
  backend "s3" {
    bucket         = var.tf_bucket_name
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.tf_table_name
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
