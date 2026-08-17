variable "project_id" {
  description = "The project ID where the firewall rule will be created."
  type        = string
}

variable "network_name" {
  description = "The VPC network name to attach the firewall rule to."
  type        = string
}

variable "bastion_tag" {
  description = "Target tag used by the bastion host VM."
  type        = string
  default     = "bastion"
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to reach the bastion via SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_port" {
  description = "SSH port to allow from the internet."
  type        = number
  default     = 22
}
    