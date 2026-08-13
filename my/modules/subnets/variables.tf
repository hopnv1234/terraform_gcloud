/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The ID of the project where subnets will be created"
  type        = string
  default = "recon-ng-56089"
}

variable "network_name" {
  description = "The name of the network where subnets will be created"
  type        = string
  default = "vpcibmlab"
}

variable "subnets_region" {
  type        = string
  description = "Optional subnets region. If set, all subnets will be created in this region."
  default     = "us-central1"
}

variable "subnets" {
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = optional(string)
    subnet_private_access            = optional(string, "false")
    subnet_private_ipv6_access       = optional(string)
    subnet_flow_logs                 = optional(string, "false")
    subnet_flow_logs_interval        = optional(string, "INTERVAL_5_SEC")
    subnet_flow_logs_sampling        = optional(string, "0.5")
    subnet_flow_logs_metadata        = optional(string, "INCLUDE_ALL_METADATA")
    subnet_flow_logs_filter          = optional(string, "true")
    subnet_flow_logs_metadata_fields = optional(list(string), [])
    description                      = optional(string)
    purpose                          = optional(string)
    role                             = optional(string)
    stack_type                       = optional(string)
    ipv6_access_type                 = optional(string)
    ip_collection                    = optional(string)
    external_ipv6_prefix             = optional(string)
  }))
  description = "The list of subnets being created"
    default = [
    {
      subnet_name           = "subnet_mgmt"
      subnet_ip             = "10.0.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      description           = "Subnet for Management"
    },
    {
      subnet_name           = "subnet_gke"
      subnet_ip             = "10.0.4.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      description           = "Subnet for GKE Workloads"
    },
    {
      subnet_name           = "Subnet_Internet"
      subnet_ip             = "10.0.0.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      description           = "Subnet for internet access"
    }
  ]
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = optional(string), reserved_internal_range = optional(string) })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}
