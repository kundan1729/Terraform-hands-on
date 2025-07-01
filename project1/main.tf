provider "aws" {
    region = "ap-south-1"
    #demo ceedentials
    access_key = "ASDFGHJKLOIUYTRERTYDCVBKJHGFSDFGJHGF2"
    secret_key = "5ii34567ujhvde45678ole45678iknxe5678ijbvr567jfr6D9k0/F8878"
}
resource "aws_instance" "terraform_server1" {
    #demo ami id
    ami = "ami-23456789ijnbvfr5678"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-linux"
    }
}