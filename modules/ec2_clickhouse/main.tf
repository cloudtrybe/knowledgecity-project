resource "aws_instance" "clickhouse" {
  count           = var.instance_count
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.clickhouse.id]

  tags = {
    Name = "${var.environment}-clickhouse-${count.index}"
    Environment = var.environment
  }

  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
    sudo yum install -y clickhouse-server clickhouse-client
    sudo systemctl start clickhouse-server
  EOT
}

resource "aws_security_group" "clickhouse" {
  name_prefix = "${var.environment}-clickhouse-"
  description = "Allow inbound traffic for ClickHouse"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8123
    to_port     = 8123
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-clickhouse-sg"
  }
}
