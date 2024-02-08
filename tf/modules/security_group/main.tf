# Declare the default security group for the specified VPC
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "generac_security_group" {
  name        = var.security_group_name
  description = "Allow web and SSH traffic"
  vpc_id      = var.vpc_id
}

# SSH access rule for the custom security group
resource "aws_security_group_rule" "ssh_rule_generac" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.public_ip}/32"]
  security_group_id = aws_security_group.generac_security_group.id
}

# HTTP and HTTPS access rules for the custom security group
resource "aws_security_group_rule" "http_https_rule_generac" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.generac_security_group.id
}

# All outbound traffic rule for the custom security group
resource "aws_security_group_rule" "all_egress_generac" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # Allows all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.generac_security_group.id
}

# SSH access rule for the default security group
resource "aws_security_group_rule" "ssh_rule_default" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.public_ip}/32"]
  security_group_id = aws_default_security_group.default.id
}

# HTTP and HTTPS access rules for the default security group
resource "aws_security_group_rule" "http_https_rule_default" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_default_security_group.default.id
}

# All outbound traffic rule for the default security group
resource "aws_security_group_rule" "all_egress_default" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # Allows all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_default_security_group.default.id
}

resource "aws_security_group_rule" "app_ingress_5000" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.generac_security_group.id
}

resource "aws_security_group_rule" "default_app_ingress_5000" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_default_security_group.default.id
}


output "id" {
  value = aws_security_group.generac_security_group.id
}

