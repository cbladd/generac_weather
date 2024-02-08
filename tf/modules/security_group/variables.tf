variable "security_group_name" {}

variable "public_ip" {
  description = "The public IP address to allow SSH access from"
  type        = string
}

variable "vpc_id" {}