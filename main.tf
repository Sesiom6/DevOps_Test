provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "simple_chat_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "simple-chat-vpc"
  }
}

resource "aws_subnet" "simple_chat_subnet" {
  vpc_id     = aws_vpc.simple_chat_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "simple-chat-subnet"
  }
}

resource "aws_security_group" "simple_chat_sg" {
  name_prefix = "sc-sg"
  vpc_id      = aws_vpc.simple_chat_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//resource "tls_private_key" "mykey" {
//  algorithm = "RSA"
//  rsa_bits  = 4096
//}

resource "aws_key_pair" "simple_chat_key" {
  key_name   = "simple-chat_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwiSLF2e81ucwW0ZWaY8aBOBxjhTv4AudrEF44JvkPyy4+Bd8v6yM4Q7+lTE26vSBeT0zs0W2ktogTbU9moHI8btEKu+X0vy37RMLijjeLuzs11/C5xE7ltUr75Kfl/ZXm3NgcOWiSDXsILyU/oC7XXwCOgU/R6S4hqMa7tIkNDhMtGfgUKfe5kUgK+8NoMqMx+XUZnm/lmBTalQxhgP9XEXlUPEBeJUlGgvArr/C0R6+qYr1dzMGfsAyBEw6XwTMdFV4Cu4SsW5fWm1/DqEABpP2kNDRd3J4Nr6+vBbgVuRwHzikcXQn9oGxX96sFBbgoG52BDc/wI8PxXD6CDZ+/ pichau@Moises"

  tags = {
    Name = "simple-chat_key"
  }
}

resource "aws_instance" "simple-chat" {
  ami                         = "ami-02396cdd13e9a1257"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.simple_chat_sg.id]
  subnet_id                   = aws_subnet.simple_chat_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.simple_chat_key.key_name
  user_data                   = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo docker pull sesiom6/simple-chat-app
              sudo docker run -d -p 80:80 sesiom6/simple-chat-app
EOF

  tags = {
    Name = "simple-chat-app-instance"
  }
}

output "public_ip" {
  value = aws_instance.simple-chat.public_ip
}

//output "public_key_openssh" {
//  value = tls_private_key.mykey.public_key_openssh
//}