

variable "Subnet12"       {}
variable "Subnet12gw"     {}
variable "Subnet12dhcp"   {}
variable "Subnet13"       {}
variable "Subnet13gw"     {}
variable "Subnet13dhcp"   {}
variable "Subnet14"       {}
variable "Subnet14gw"     {}

data "nsxt_policy_tier0_gateway" "vmc" {
  display_name = "vmc"
}

data "nsxt_policy_transport_zone" "TZ" {
  display_name = "vmc-overlay-tz"
}
/*======================================
Need to import the existing infra.
1 - delete default rules (we will recreate them below)
2 - use
    - terraform import module.NSX.nsxt_policy_gateway_policy.mgw mgw/default
and
    - terraform import module.NSX.nsxt_policy_gateway_policy.cgw cgw/default


Scope for MGW is "/infra/labels/mgw"
Scope for CGW (applied to:) are:
  INTERNET: "/infra/labels/cgw-public"
  DX:       "/infra/labels/cgw-direct-connect"  
  VPN:      "/infra/labels/cgw-vpn"  
  VPC:      "/infra/labels/cgw-cross-vpc"  
  ALL:      "/infra/labels/cgw-all"  


T0 groups
---------
Connected VPC:    "/infra/tier-0s/vmc/groups/connected_vpc",
S3 Prefixes:      "/infra/tier-0s/vmc/groups/s3_prefixes",
Direct Connect:   "/infra/tier-0s/vmc/groups/directConnect_prefixes"

========================================*/

/*========
MGW rules
=========*/
resource "nsxt_policy_gateway_policy" "mgw" {
  category                = "LocalGatewayRules"
  description             = "Terraform provisioned Gateway Policy"
  display_name            = "default"
  domain                  = "mgw"
  # New rules below . . 
  # Order in code below is order in GUI 
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/ESXI"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Provisionning"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/VMware_Remote_Console"

    ]
    source_groups         = []
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Inbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/SSO"
    ]
    source_groups    = []
    sources_excluded = false
  }

  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Outbound Rule"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = []
    source_groups         = ["/infra/domains/mgw/groups/ESXI"]
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Outbound Rule"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services = []
    source_groups         = ["/infra/domains/mgw/groups/VCENTER"]
    sources_excluded = false
  }
}

/*========
CGW rules
=========*/

resource "nsxt_policy_gateway_policy" "cgw" {
  category              = "LocalGatewayRules"
  description           = "Terraform provisioned Gateway Policy"
  display_name          = "default"
  domain                = "cgw"
  # New rules below . . 
  # Order in code below is order in GUI  
  rule {
    action = "ALLOW"
    destination_groups    = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "VMC to AWS"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services = []
    source_groups    = []
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "AWS to VMC"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services = []
    source_groups    = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Internet out"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-public"]
    services = []
    source_groups    = [
      nsxt_policy_group.group12.path,
      nsxt_policy_group.group13.path
      ]
    sources_excluded = false
  }

  rule {
    action = "DROP"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Default VTI Rule"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-vpn"]
    services = []
    source_groups         = []
    sources_excluded = false
  }
}

/*==============
Create segments
===============*/

resource "nsxt_policy_segment" "segment12" {
  display_name        = "segment12"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr              = var.Subnet12gw
    dhcp_ranges       = [var.Subnet12dhcp]
  }
}
resource "nsxt_policy_segment" "segment13" {
  display_name        = "segment13"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr = var.Subnet13gw
    dhcp_ranges = [var.Subnet13dhcp]
  }
}
resource "nsxt_policy_segment" "segment14" {
  display_name        = "segment14"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr = var.Subnet14gw
  }
}

/*==============
Create Groups
===============*/

resource "nsxt_policy_group" "group12" {
  display_name = "tf-group12"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet12]
    }
  }
}
resource "nsxt_policy_group" "group13" {
  display_name = "tf-group13"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet13]
    }
  }
}
resource "nsxt_policy_group" "group14" {
  display_name = "tf-group14"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet14]
    }
  }
}
output "segment12_name"     {value = nsxt_policy_segment.segment12.display_name}
output "segment13_name"     {value = nsxt_policy_segment.segment13.display_name}


