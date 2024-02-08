variable "vpc_id" {}
variable "gateway_name" {}

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.gateway_name
  }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}
