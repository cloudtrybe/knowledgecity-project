resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name      = "${environment}-ecr"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}