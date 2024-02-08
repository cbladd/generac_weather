variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "public_ip" {}
variable "private_key_path" {}

resource "aws_instance" "generac_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  associate_public_ip_address = true  


  tags = {
    Name = "generac"
  }
  
  # other configurations
}

output "public_ip" {
  value = aws_instance.generac_instance.public_ip
}
