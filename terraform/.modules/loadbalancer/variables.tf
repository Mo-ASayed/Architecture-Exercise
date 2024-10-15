variable "alb_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "target_group_name" {
  type = string
}

variable "port" {
  type = number
}

variable "vpc_id" {
  type = string
}
