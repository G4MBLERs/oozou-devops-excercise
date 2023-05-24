provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

variable "prefix" {
  description = "servername prefix"
  default = "oozou-server"
}

resource "aws_security_group" "oozou-server-sg" {
  name        = "oozou-sg"
  description = "Allow incoming traffic to the Linux EC2 Instance"
  vpc_id      = "vpc-1320075"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming grafana connections"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "oozou-server" {
  ami           = "ami-007a18d38016a0f4e"
  instance_type = "t3.small"
  count = 1
  vpc_security_group_ids = [
    "aws_security_group.oozou-server-sg"
  ]
  user_data = <<EOF
#!/bin/bash
echo "update and install git, docker, docker-compose, nodejs"
apt-get -y update && apt-get install -y --no-install-recommends \
  apt-utils \
  git \
  docker \
  docker-compose 
echo "Clone oozou project"
git clone https://github.com/G4MBLERs/oozou-devops-excercise
echo "Deployment"
docker-compose up -d --build
EOF
  subnet_id = "subnet-00514b9f4cd6d4"
  tags = {
    Name = "${var.prefix}${count.index}"
  }
}

output "instances" {
  value       = "${aws_instance.oozou-server.*.public_ip}"
  description = "PublicIP address details"
}
