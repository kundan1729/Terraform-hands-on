provider "aws" {
  region  = "ap-south-1"
  profile = "terraform_aws"
}

# EC2 Instance
resource "aws_instance" "linux" {
  ami                    = "ami-0d03cb826412c6b0f"
  instance_type          = "t2.micro"
  

  tags = {
    Name = "EC2_SECURITY_GROUP"
  }
}

# Fetch Default VPC
data "aws_vpc" "default" {
  default = true
}

# Custom Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_tls"
  }
}

# Ingress Rule for IPv4 - Allow HTTPS (TLS) traffic
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"                      # allow from anywhere
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from anywhere"
}

# Optional: Ingress Rule for IPv6 (if needed)
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"                          # allow from all IPv6
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from all IPv6"
}

# Outbound Rule (Egress) - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # all protocols
  description       = "Allow all outbound traffic"
}
