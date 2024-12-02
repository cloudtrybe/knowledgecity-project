variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "services" {
  type = map(object({
    service_name           = string
    image                  = string
    port                   = number
    cpu                    = number
    memory                 = number
    environment            = list(map(string))
    desired_count          = number
    assign_public_ip       = bool
    health_check_path      = string
    path_patterns          = list(string)
    max_capacity           = number
    min_capacity           = number
    scale_out_target_value = number
    scale_in_target_value  = number
  }))
}

variable "alb_security_group_id" {

}

variable "alb_listener_arn" {

}

variable "enable_service_autoscaling" {
  type    = bool
  default = false
}
