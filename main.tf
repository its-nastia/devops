provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  key_name      = "devops2"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "FullStack Deployment"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              PUBLIC_IP=$(curl -s https://api.ipify.org)
              curl -X GET "https://devops:11653bd900a61a61152c8caab3b8f24def@jenkins-ops.portnov.com/job/nastia-tf-task/buildWithParameters?token=Abc123456&MANAGED_HOST=$PUBLIC_IP"
              EOF
}

resource "aws_security_group" "web_sg" {
  name        = "terraform-web-sg"
  description = "Allow HTTP traffic on port 80"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}
