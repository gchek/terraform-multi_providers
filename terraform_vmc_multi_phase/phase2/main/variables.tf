/*================
REGIONS map:
==================
us-east-1       US East (N. Virginia)
us-east-2	      US East (Ohio)
us-west-1	      US West (N. California)
us-west-2	      US West (Oregon)
ca-central-1	  Canada (Central)
eu-west-1	      EU (Ireland)
eu-central-1	  EU (Frankfurt)
eu-west-2	      EU (London)
ap-northeast-1	Asia Pacific (Tokyo)
ap-northeast-2	Asia Pacific (Seoul)
ap-southeast-1	Asia Pacific (Singapore)
ap-southeast-2	Asia Pacific (Sydney)
ap-south-1	    Asia Pacific (Mumbai)
sa-east-1	      South America (São Paulo)
=================*/




variable "vmc_token"  {}

/*================
Subnets IP ranges
=================*/
variable "VMC_subnets" {
  default = {

    Subnet12            = "10.10.12.0/24"
    Subnet12gw          = "10.10.12.1/24"
    Subnet12dhcp        = "10.10.12.100-10.10.12.200"

    Subnet13            = "10.10.13.0/24"
    Subnet13gw          = "10.10.13.1/24"
    Subnet13dhcp        = "10.10.13.100-10.10.13.200"

    Subnet14            = "10.10.14.0/24"
    Subnet14gw          = "10.10.14.1/24"
  }
}



