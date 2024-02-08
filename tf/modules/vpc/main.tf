variable "cidr_block" {}
variable "vpc_name" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
