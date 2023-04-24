provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "simple_chat_sg" {
  name_prefix = "sc-sg"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "simple-chat" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  user_data = <<-EOF
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
  value = aws_instance.example.public_ip
}
