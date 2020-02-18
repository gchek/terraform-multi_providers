

variable "key_pair"             {}
variable "VM-AMI"               {}

variable "Subnet10-vpc1"        {}
variable "Subnet10-vpc1-base"   {}
variable "GC-SG-VPC1"           {}


/*================
EC2 Instances
=================*/
resource "aws_network_interface" "VM1-Eth0" {
  subnet_id                     = var.Subnet10-vpc1
  security_groups               = [var.GC-SG-VPC1]
  private_ips                   = [cidrhost(var.Subnet10-vpc1-base, 99)]
}
resource "aws_instance" "VM1" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "GCTF-VM1-vpc1"
  }
}

/*=====================
Cloud-init file for VM2
======================*/

data "template_file" "user_data" {
  template = file("${path.module}/user-data.tpl")
}

resource "aws_network_interface" "VM2-Eth0" {
  subnet_id                     = var.Subnet10-vpc1
  security_groups               = [var.GC-SG-VPC1]
  private_ips                   = [cidrhost(var.Subnet10-vpc1-base, 100)]
}
resource "aws_instance" "VM2" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM2-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  user_data                     = data.template_file.user_data.rendered

  tags = {
    Name = "GCTF-VM2-vpc1"
  }
}

/*================
Outputs variables for other modules to use
=================*/


output "EC2_1_IP"           {value = aws_instance.VM1.public_ip}
output "EC2_2_IP"           {value = aws_instance.VM2.public_ip}
