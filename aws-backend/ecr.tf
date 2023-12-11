# resource "aws_ecr_repository" "ghost" {
#   name                 = "ghost"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = false
#   }
#   encryption_configuration {
#     encryption_type = "AES256" # Set to KMS to use KMS encryption
#   }
# }
import {
  to = aws_ecr_repository.ghost
  id = "ghost"
}

resource "aws_ecr_repository" "ghost" {
  force_delete         = null
  image_tag_mutability = "MUTABLE"
  name                 = "ghost"
  tags = {
    Environment = "Prod"
    Project     = "Ghost"
  }
  encryption_configuration {
    encryption_type = "AES256"
    kms_key         = null
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}
