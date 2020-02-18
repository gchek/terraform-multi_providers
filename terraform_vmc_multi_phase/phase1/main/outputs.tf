/*================
Outputs from Various Module
=================*/

output "sddc_subnet"            {value = module.VPCs.Subnet10-vpc1}
output "proxy_url"              {value = module.SDDC.proxy_url}
output "VM1_IP"                 {value = module.EC2s.EC2_1_IP}
output "VM2_IP"                 {value = module.EC2s.EC2_2_IP}
output "vc_url"                 {value = module.SDDC.vc_url}
output "cloud_username"         {value = module.SDDC.cloud_username}
output "cloud_password"         {
  sensitive = true
  value = module.SDDC.cloud_password
}



