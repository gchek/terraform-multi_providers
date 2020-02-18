
provider "aws" {
  access_key            = var.access_key
  secret_key            = var.secret_key
  region                = var.AWS_region
}

provider "vmc" {
  refresh_token         = var.vmc_token
}

terraform {
  backend "local" {
    path = "../../phase1.tfstate"
  }
}

/*================
Create AWS VPCs
The VPCs and subnets CIDR are set in "variables.tf" file
=================*/
module "VPCs" {
  source = "../VPCs"

  vpc1_cidr             = var.My_subnets["VPC1"]
  Subnet10-vpc1         = var.My_subnets["Subnet10-vpc1"]
  region                = var.AWS_region

}

/*================
Create EC2s
=================*/
module "EC2s" {

  source = "../EC2s"

  VM-AMI                = var.VM_AMI
  Subnet10-vpc1         = module.VPCs.Subnet10-vpc1
  Subnet10-vpc1-base    = var.My_subnets["Subnet10-vpc1"]
  GC-SG-VPC1            = module.VPCs.GC-SG-VPC1
  key_pair              = var.key_pair

}
/*================
Create SDDC
=================*/

module "SDDC" {

  source = "../SDDC"

  my_org_id             = var.my_org_id               # ORG ID from secrets
  SDDC_Mngt             = var.My_subnets["SDDC_Mngt"] # Management IP range
  SDDC_def              = var.My_subnets["SDDC_def"]  # Default SDDC Segment
  customer_subnet_id    = module.VPCs.Subnet10-vpc1   # VPC attached subnet
  VMC_region            = var.VMC_region              # AWS region
  AWS_account           = var.AWS_account             # Your AWS account
}


