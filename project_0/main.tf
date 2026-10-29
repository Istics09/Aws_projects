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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  user_data_replace_on_change = true
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.main.key_name

  tags = {
    Name = "My_EC_withoutAI"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    echo "<h1>Yellow big world!</h1><p>This is my website! <br><b>Terrafrom learning</b></p>" > /var/www/html/index.html
  EOF
}

resource "aws_security_group" "web" {
  name = "Security"
  description = "SSH & HTTP allow"

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Accessing others"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "main"{
  key_name = "tf_key"
  public_key = file("~/.ssh/aws_tf.pub")
}

