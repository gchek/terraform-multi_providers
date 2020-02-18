variable "my_org_id" {}          
variable "SDDC_Mngt" {}           
variable "SDDC_def" {}           
variable "customer_subnet_id" {}
variable "VMC_region" {}
variable "AWS_account" {}



data "vmc_org" "my_org" {
  id = var.my_org_id
}
data "vmc_connected_accounts" "my_accounts" {
  org_id = data.vmc_org.my_org.id
  account_number = var.AWS_account
}
data "vmc_customer_subnets" "my_subnets" {
  org_id               = data.vmc_org.my_org.id
  connected_account_id = data.vmc_connected_accounts.my_accounts.ids[0]
  region               = var.VMC_region
}



resource "vmc_sddc" "TF_SDDC" {
    org_id              = data.vmc_org.my_org.id
    sddc_name           = "TF_SDDC1"
    vpc_cidr            = var.SDDC_Mngt
    num_host            = 1
    provider_type       = "AWS"
    region              = data.vmc_customer_subnets.my_subnets.region
    vxlan_subnet        = var.SDDC_def
    delay_account_link  = false
    skip_creating_vxlan = false
    sso_domain          = "vmc.local"
    deployment_type     = "SingleAZ"
    sddc_type           = "1NODE"
    account_link_sddc_config {
        customer_subnet_ids  = [var.customer_subnet_id]
        connected_account_id = data.vmc_connected_accounts.my_accounts.ids[0]
    }
    timeouts {
        create = "300m"
        update = "300m"
        delete = "180m"
    }
}

output "proxy_url"      {value = trimsuffix(trimprefix(vmc_sddc.TF_SDDC.nsxt_reverse_proxy_url, "https://"), "/sks-nsxt-manager")}
output "vc_url"         {value = trimsuffix(trimprefix(vmc_sddc.TF_SDDC.vc_url, "https://"), "/")}
output "cloud_username" {value = vmc_sddc.TF_SDDC.cloud_username}
output "cloud_password" {value = vmc_sddc.TF_SDDC.cloud_password}
