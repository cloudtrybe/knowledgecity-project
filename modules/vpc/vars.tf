variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  #default     = "172.17.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use for the VPC"
  type        = number
  #default     = 1
}
