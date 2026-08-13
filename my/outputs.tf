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

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "project_id" {
  value       = module.vpc.project_id
  description = "VPC project id"
}

output "subnets_names" {
  value       = [for subnet in module.subnets.subnets : subnet.name]
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = [for subnet in module.subnets.subnets : subnet.ip_cidr_range]
  description = "The IP CIDR ranges of the subnets being created"
}

output "subnets_regions" {
  value       = [for subnet in module.subnets.subnets : subnet.region]
  description = "The regions where subnets will be created"
}

output "subnets_private_access" {
  value       = [for subnet in module.subnets.subnets : subnet.private_ip_google_access]
  description = "Whether the subnets will have access to Google APIs without a public IP"
}
output "subnets_secondary_ranges" {
  value       = [for subnet in module.subnets.subnets : subnet.secondary_ip_range]
  description = "The secondary ranges associated with these subnets"
}
output "subnets_flow_logs" {
  value       = [for subnet in module.subnets.subnets : subnet.enable_flow_logs]
  description = "Whether the subnets will have VPC flow logs enabled"
}
/*
output "route_names" {
  value       = []
  description = "The routes associated with this VPC"
}
*/