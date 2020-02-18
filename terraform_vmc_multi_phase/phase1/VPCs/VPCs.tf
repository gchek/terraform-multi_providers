
/*================
Create VPCs
Create respective Internet Gateways
Create subnets
Create route tables
create security groups
=================*/

variable "vpc1_cidr"      {}
variable "Subnet10-vpc1"  {}
variable "region"         {}


/*================
VPCs
=================*/
resource "aws_vpc" "vpc1" {
  cidr_block            = var.vpc1_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "GCTF-VPC1"
  }
}

/*================
IGWs
=================*/

resource "aws_internet_gateway" "vpc1-igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "GCTF-VPC1-IGW"
  }

}

/*================
Subnets in VPC1
=================*/

# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "Subnet10-vpc1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.Subnet10-vpc1
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "GCTF-Subnet10-vpc1"
  }
}




/*================
default route table VPC1
=================*/

resource "aws_default_route_table" "vpc1-RT" {
  default_route_table_id = aws_vpc.vpc1.default_route_table_id

  lifecycle {
    ignore_changes = [route] # ignore any manually or ENI added routes
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1-igw.id
  }

  tags = {
    Name = "GCTF-RT-VPC1"
  }
}



/*================
Route Table association
=================*/

resource "aws_route_table_association" "vpc1_10" {
  subnet_id      = aws_subnet.Subnet10-vpc1.id
  route_table_id = aws_default_route_table.vpc1-RT.id
}


/*================
Security Groups
=================*/

resource "aws_security_group" "GC-SG-VPC1" {
  name    = "GC-SG-VPC1"
  vpc_id  = aws_vpc.vpc1.id
  tags = {
    Name = "GCTF-SG-VPC1"
  }
  #SSH and all PING
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all PING"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow iPERF3"
    from_port = 5201
    to_port = 5201
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_default_security_group" "default" {

  vpc_id = aws_vpc.vpc1.id

  ingress {
    description = "Default SG for VPC1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress{
     description = "Include EC2 SG in VPC1 default SG"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     security_groups = [aws_security_group.GC-SG-VPC1.id]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Default VPC1-SG"
  }
}




/*================
S3 Gateway end point
=================*/

 resource "aws_vpc_endpoint" "s3" {
   vpc_id          = aws_vpc.vpc1.id
   service_name    = "com.amazonaws.${var.region}.s3"
   route_table_ids = [aws_default_route_table.vpc1-RT.id]
 }



/*================
Outputs variables for other modules to use
=================*/
output "VPC1_id"              {value = aws_vpc.vpc1.id}
output "Subnet10-vpc1"        {value = aws_subnet.Subnet10-vpc1.id}
output "GC-SG-VPC1"           {value = aws_security_group.GC-SG-VPC1.id}






