variable "vpc_id" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "subnet_name" {}

resource "aws_subnet" "main" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  }
}

output "subnet_id" {
  value = aws_subnet.main.id
}
