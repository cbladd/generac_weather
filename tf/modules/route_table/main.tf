variable "vpc_id" {}
variable "internet_gateway_id" {}

resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = var.vpc_id
  route_table_id = aws_route_table.main.id
}

output "route_table_id" {
  value = aws_route_table.main.id
}
