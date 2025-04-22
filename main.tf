provider "aws" {
    region = "eu-west-1"
}


variable "vpc-cidr-block" {}
variable subnet-cidr-block {}
variable avail-zone {}
variable env-prefix {}
variable instance-type {}
variable public-key-location {}



resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}


resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet-cidr-block
  availability_zone = var.avail-zone
  tags = {
    Name : "${var.env-prefix}-subnet-1"
  }
}  

resource "aws_internet_gateway" "myapp-igw" {
   vpc_id = aws_vpc.myapp-vpc.id
}

resource "aws_route_table" "myapp-route-table" {
   vpc_id = aws_vpc.myapp-vpc.id

   route  {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.myapp-igw.id
   }
   tags = {
     Name = "${var.env-prefix}-route-table"
   }
}

resource "aws_route_table_association" "myapp-rtb-assosiation" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
   name = "myapp-sg"
   vpc_id = aws_vpc.myapp-vpc.id

   ingress {
    # range of ports for incomming traffic
    from_port = 22   
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
    # range of ports for incomming traffic
    from_port = 8000   
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress  {
    from_port = 0   
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
   }

   tags = {
     Name = "${var.env-prefix}-sg"
   }
}


data "aws_ami" "latest-amazon-machine-image" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws-ami" {
   value = data.aws_ami.latest-amazon-machine-image.id
}


resource "aws_key_pair" "myapp-key" {
  key_name = "myapp-key"
  public_key = "${file(var.public-key-location)}"
}



resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.latest-amazon-machine-image.id
    instance_type = var.instance-type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail-zone

    associate_public_ip_address = true
    key_name = aws_key_pair.myapp-key.key_name


    user_data = file("entry-script.sh")

    tags = {
      Name = "${var.env-prefix}-instance"
    }
}

output "ec2-public-ip" {
   value = aws_instance.myapp-ec2.public_ip
}  