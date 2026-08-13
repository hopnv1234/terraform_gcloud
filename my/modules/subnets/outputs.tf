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

output "subnets" {
  value = {
    for k, v in google_compute_subnetwork.subnetwork :
    k => {
      name           = v.name
      id             = v.id
      region         = v.region
      ip_cidr_range  = v.ip_cidr_range
      self_link      = v.self_link
      gateway_address = v.gateway_address
    }
  }
  description = "Useful subnet metadata"
}