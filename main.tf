resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}

module "myapp-subnet" {
  source            = "./modules/subnet"
  subnet-cidr-block = var.subnet-cidr-block
  avail-zone        = var.avail-zone
  env-prefix        = var.env-prefix
  myapp-vpc-id      = aws_vpc.myapp-vpc.id

}


module "webserver" {
  source              = "./modules/webserver"
  vpc-id              = aws_vpc.myapp-vpc.id
  env-prefix          = var.env-prefix
  public-key-location = var.private-key-location
  instance-type       = var.instance-type
  avail-zone          = var.avail-zone
  image-name          = var.image-name
  subnet-id           = module.myapp-subnet.subnet

}