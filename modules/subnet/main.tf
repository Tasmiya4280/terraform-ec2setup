resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = var.myapp-vpc-id
  cidr_block        = var.subnet-cidr-block
  availability_zone = var.avail-zone
  tags = {
    Name : "${var.env-prefix}-subnet-1"
  }
}  

resource "aws_internet_gateway" "myapp-igw" {
   vpc_id = var.myapp-vpc-id
}

resource "aws_route_table" "myapp-route-table" {
   vpc_id = var.myapp-vpc-id

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