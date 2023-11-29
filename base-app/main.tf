terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0" # Specify the version you want to use
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

resource "aws_key_pair" "ghost_ec2_pool" {
  key_name   = "ghost-ec2-pool"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTrdwoPLn6sFs0A5YGlGqkkQsRXg6LVZSR2l/81MzxJ dmitry.yemelin@xa.epicgames.com"
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0e8a34246278c21e4" # Replace with the latest Amazon Linux 2 AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public["subnet_a"].id
  associate_public_ip_address = true

  # Security Group
  vpc_security_group_ids = [aws_security_group.bastion.id] # Replace with your bastion security group ID

  # SSH Key
  key_name = "ghost-ec2-pool" # Replace with your key pair name

  tags = {
    Name = "bastion"
  }
}

# resource "aws_instance" "example" {
#   ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.ghost_ec2_pool.id
# }
