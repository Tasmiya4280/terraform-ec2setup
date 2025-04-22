resource "aws_security_group" "myapp-sg" {
   name = "myapp-sg"
   vpc_id = var.vpc-id

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
    values = [var.image-name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "myapp-key" {
  key_name = "myapp-key"
  public_key = file(var.public-key-location)
}



resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.latest-amazon-machine-image.id
    instance_type = var.instance-type

    subnet_id  = var.subnet-id

    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail-zone

    associate_public_ip_address = true
    key_name = "myapp-key"


    user_data = file("entry-script.sh")

    # connection {
    #   type = "ssh"
    #   host = self.public_ip
    #   user = "ec2-user"
    #   private_key = file(var.private-key-location)
    # }
    # provisioner "file" {
    #   source = "entry-script.sh"
    #   destination = "/home/ec2-user/entry-script-on-ec2.sh"
    # }
    # provisioner "remote-exec" {

    #    script = file("entry-script-on-ec2.sh")

    # }
    
    # provisioner "local-exec" {
    #    command = "echo ${self.public_ip} > output.txt"
    # }

    tags = {
      Name = "${var.env-prefix}-instance"
    }
}

