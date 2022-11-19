terraform {
  cloud {
    organization = "rgoshen-org"
    workspaces {
      name = "learn-tfc-aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-09a41e26df464c548"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
