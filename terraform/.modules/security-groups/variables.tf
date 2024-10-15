variable "vpc_id" {
  type = string
}

variable "service_port" {
  type = number
}

variable "tags" {
  type = map(string)
}
