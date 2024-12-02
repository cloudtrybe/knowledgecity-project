variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vault_token" {
  type = string
}

variable "account_id" {
  type = string
}

###########VPC#################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  #default     = "172.17.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use for the VPC"
  type        = number
  default     = 1
}

############ ECR ##############
variable "force_delete" {
  type = bool
}

variable "ecr_name" {
  type = string
}

############ certificate manager ##############
variable "domain_name" {
  type = string
}

############mysql##############
variable "engine_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "publicly_accessible" {
  type = bool
}

variable "port" {

}

variable "multi_az" {
  type = bool
}