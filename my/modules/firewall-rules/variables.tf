variable "project_id" {
  description = "The project ID where the firewall rule will be created."
  type        = string
}

variable "network_name" {
  description = "The VPC network name to attach the firewall rule to."
  type        = string
}

variable "target_tag" {
  description = "Target network tag used by the VMs receiving this firewall rule."
  type        = string
  default     = "mgmt"
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to reach the target VMs via SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_port" {
  description = "SSH port to allow from the internet."
  type        = number
  default     = 22
}

variable "vpn_bgp_source_ranges" {
  description = "On-premises CIDR ranges allowed to establish IPsec and BGP connections."
  type        = list(string)
  default     = ["192.168.210.0/24"]
}

variable "vpn_internal_source_ranges" {
  description = "On-premises and link-local CIDR ranges allowed to send internal ICMP traffic."
  type        = list(string)
  default     = ["192.168.210.0/24", "169.254.0.0/16"]
}

variable "onprem_to_vpc_source_ranges" {
  description = "On-premises CIDR ranges allowed to send TCP, UDP, and ICMP traffic to the VPC."
  type        = list(string)
  default     = ["192.168.210.0/24"]
}
    