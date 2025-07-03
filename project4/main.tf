provider "aws" {
  region  = "ap-south-1"
  profile = "terraform_aws"
}


resource "aws_instance" "linux" {
  ami                    = "ami-0d03cb82234326412c6b0f"
  instance_type          = "t2.micro"
  

  tags = {
    Name = "EC2_SECURITY_GROUP"
  }
}


data "aws_vpc" "default" {
  default = true
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"                      
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from anywhere"
}


resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"                          
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from all IPv6"
}


resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # all protocols
  description       = "Allow all outbound traffic"
}
