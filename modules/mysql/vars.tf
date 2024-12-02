variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "engine_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "availability_zone" {

}

variable "deletion_protection" {
  type = bool
}

# variable "kms_key_id" {

# }

variable "publicly_accessible" {
  type = bool
}

variable "port" {

}

variable "multi_az" {
  type = bool
}