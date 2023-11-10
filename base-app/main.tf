terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "Prod"
      Project     = "Ghost"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "dmitry-yemelin-ghost-terraform-state" // Bucket where to SAVE Terraform State
    key    = "prod/terraform.tfstate"               // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                            // Region where bycket created
  }
}



# resource "aws_instance" "example" {
#   ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
#   instance_type = "t2.micro"
# }
