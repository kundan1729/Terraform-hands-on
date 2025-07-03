provider "aws"{
 region = "ap-south-1"
 profile = "terraform_aws"

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "Security_sample" {
 ami = data.aws_ami.ubuntu.id
 instance_type = "t2.micro"
 tags = {
 Name = "EC2_Security_Groups"
 }
}
#use the default VPC
data "aws_vpc" "default" {
 default = true
}

resource "aws_security_group" "HTTP" {
 name = "network"
 description = "Allow TLS inbound traffic and all outbound traffic"
 vpc_id = data.aws_vpc.default.id
 tags = {
 Name = "network"
 }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
 security_group_id = aws_security_group.allow_tls.id
 cidr_ipv4 = data.aws_vpc.default.cidr_block 
 from_port = 443
 ip_protocol = "tcp"
 to_port = 443
}

# Ingress Rule for IPv6 - HTTPS traffic within the VPC
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
 security_group_id = aws_security_group.allow_tls.id
 cidr_ipv6 = "::/0"
 from_port = 443
 ip_protocol = "tcp"
 to_port = 443
}
# Egress Rule - Allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
 security_group_id = aws_security_group.allow_tls.id
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
 security_group_id = aws_security_group.allow_tls.id
 cidr_ipv6 = "::/0"
 ip_protocol = "-1" 
}

#ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
 security_group_id = aws_security_group.allow_tls.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 22
 ip_protocol = "tcp"
 to_port = 22
}

