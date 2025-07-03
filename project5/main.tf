provider "aws" {
    region = "ap-south-1"
    profile = "terraform_aws"  
}

resource "aws_instance" "SSH instance" {
    ami = ""
    instance_type = "t2.micro"

    tags ={
        Name =" EC2 Security Group"
    }

}