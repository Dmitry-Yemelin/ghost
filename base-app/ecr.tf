resource "aws_ecr_repository" "ghost" {
  name                 = "ghost"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "AES256" # Set to KMS to use KMS encryption
  }
}
