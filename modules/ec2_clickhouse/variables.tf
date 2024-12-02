variable "instance_count" {
  description = "Number of ClickHouse instances"
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the instances will be deployed"
  type        = string
}

variable "allowed_ips" {
  description = "Allowed CIDR blocks for inbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}
