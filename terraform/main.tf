provider "aws" {
  region = "ap-south-1"
}

variable "my_ip" {}
variable "public_key" {}

resource "aws_vpc" "inventory-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "inventory-vpc"
  }
}

resource "aws_subnet" "inventory-subnet" {
  vpc_id                  = aws_vpc.inventory-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "inventory-subnet"
  }
}

resource "aws_internet_gateway" "inventory-gw" {
  vpc_id = aws_vpc.inventory-vpc.id

  tags = {
    Name = "inventory-gw"
  }
}

resource "aws_route_table" "inventory-rtb" {
  vpc_id = aws_vpc.inventory-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inventory-gw.id
  }

  tags = {
    Name = "inventory-rtb"
  }
}

resource "aws_route_table_association" "inventory-rtb-association" {
  subnet_id      = aws_subnet.inventory-subnet.id
  route_table_id = aws_route_table.inventory-rtb.id
}

resource "aws_security_group" "inventory-sg" {
  name   = "inventory-sg"
  vpc_id = aws_vpc.inventory-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Name = "inventory-sg"
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "server_key"
  public_key = file(var.public_key)
}

resource "aws_instance" "machine-1" {
  ami           = "ami-04808bdb94be6720e"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.inventory-subnet.id
  vpc_security_group_ids      = [aws_security_group.inventory-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh.key_name

  tags = {
    Name = "machine-1"
  }
}

resource "aws_instance" "machine-2" {
  ami           = "ami-04808bdb94be6720e"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.inventory-subnet.id
  vpc_security_group_ids      = [aws_security_group.inventory-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh.key_name

  tags = {
    Name = "machine-2"
  }
}

resource "aws_instance" "machine-3" {
  ami           = "ami-04808bdb94be6720e"
  instance_type = "t3.small"

  subnet_id                   = aws_subnet.inventory-subnet.id
  vpc_security_group_ids      = [aws_security_group.inventory-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh.key_name
  tags = {
    Name = "machine-3"
  }
}