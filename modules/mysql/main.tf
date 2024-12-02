resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    name      = "${terraform.workspace}-db-subnet-group"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${terraform.workspace}-db"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  availability_zone    = var.availability_zone
  deletion_protection  = var.deletion_protection
  port                 = var.port
  #   kms_key_id = var.kms_key_id
  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true

  tags = {
    name      = "${terraform.workspace}-rds-msql"
    Automated = "yes"
    CreatedBy = "Terraform"
  }
}