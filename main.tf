provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "docker" {
  name_prefix = "docker-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker" {
  ami                    = "ami-03c7d01cf4dedc891"
  instance_type          = "t2.micro"
  key_name               = "moises"
  vpc_security_group_ids = [aws_security_group.docker.id]
  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extra install docker -y
            sudo service docker start
            sudo systemctl enable docker
            sudo usermod -a -G docker ec2-user
            sudo docker pull sesiom6/simple-chat-app:v1
            sudo docker run -d -p 80:3000 sesiom6/simple-chat-app:v1
EOF

  tags = {
    Name = "docker-instance"
  }
}

resource "aws_eip" "docker" {
  instance = aws_instance.docker.id

  tags = {
    Name = "docker-eip"
  }
}

output "public_ip" {
  value = aws_eip.docker.public_ip
}