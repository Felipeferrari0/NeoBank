data "aws_vpc" "default" {
  default = true
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "neobank_key" {
  key_name   = "neobank-key"
  public_key = file("C:/Users/FelipeFerrari/OneDriveIBM/Documentos/NeoBank/keys/neobank-key.pub")
}


resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Allow SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    self             = false
    prefix_list_ids  = []
  }

  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    self             = false
    prefix_list_ids  = []
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    self             = false
    prefix_list_ids  = []
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0c803b171269e2d72"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.neobank_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "neobank"
  }

  provisioner "local-exec" {
    command = <<EOT
echo "[web]" > ../ansible/inventory.ini
echo "${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/neobank-key.pem" >> ../ansible/inventory.ini
EOT
  }
}
