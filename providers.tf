terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias = "aws_us_east_1"
  region = "us-east-1"
}
