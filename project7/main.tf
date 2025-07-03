provider "aws" {
  region  = "ap-south-1"
  profile = "terraform_aws"
}

# 🔍 Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# 🔍 Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# 🔒 Security Group - Allow HTTP & SSH Inbound, All Outbound
resource "aws_security_group" "allow_http_ipv4" {
  name        = "allow_http"
  description = "Allow HTTP and SSH inbound traffic, all outbound"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_http"
  }
}

# ✅ HTTP Ingress
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP traffic from anywhere"
}

# ✅ SSH Ingress
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH traffic from anywhere"
}

# ✅ IPv6 HTTP Ingress (optional)
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.allow_http_ipv4.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP traffic from all IPv6"
}

# ✅ All Egress
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.allow_http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# 🚀 Launch EC2 Instance
resource "aws_instance" "linux" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_ipv4.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
            EOF

  tags = {
    Name = "security-group-project"
  }
}

# 📤 Output public IP
output "instance_public_ip" {
  value       = aws_instance.linux.public_ip
  description = "Public IP address of EC2"
}
