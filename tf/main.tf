provider "aws" {
  region = "us-west-2" 
}

# Data source to fetch the current public IP address
data "http" "current_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Create a new VPC
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"  
  vpc_name = "generac_vpc"
}

# Create a new Subnet
module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  subnet_cidr_block = "10.0.1.0/24"  
  availability_zone = "us-west-2a"  
  subnet_name = "generac_subnet"
}

# Create an Internet Gateway
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  gateway_name = "generac_gateway"
}

# Create a Route Table
module "route_table" {
  source = "./modules/route_table"
  vpc_id = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
}

# EC2 Instance
module "instance" {
  source = "./modules/instance"

  ami = "ami-0c0ba4e76e4392ce9"
  instance_type = "t2.micro"
  key_name = "infrastructure-20230105"
  subnet_id = module.subnet.subnet_id
  public_ip = data.http.current_ip.body
  private_key_path = "../keys/infrastructure-20230105.pem"
}

locals {
  trimmed_public_ip = trimspace(data.http.current_ip.body)
}

# Security Group
module "security_group" {
  source = "./modules/security_group"

  vpc_id = module.vpc.vpc_id
  security_group_name = "generac_security_group"
  public_ip = local.trimmed_public_ip
}
