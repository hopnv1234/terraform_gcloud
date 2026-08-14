/**
 * Copyright 2018 Google LLC
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

output "bastion_host_name" {
  description = "Name of the bastion host VM"
  value       = google_compute_instance.bastion-host.name
}

output "bastion_host_self_link" {
  description = "Self link of the bastion host VM"
  value       = google_compute_instance.bastion-host.self_link
}

output "gitlab_ce_name" {
  description = "Name of the GitLab CE VM"
  value       = google_compute_instance.gitlab-ce.name
}

output "gitlab_ce_self_link" {
  description = "Self link of the GitLab CE VM"
  value       = google_compute_instance.gitlab-ce.self_link
}

output "tfe_name" {
  description = "Name of the TFE VM"
  value       = google_compute_instance.tfe.name
}

output "tfe_self_link" {
  description = "Self link of the TFE VM"
  value       = google_compute_instance.tfe.self_link
}

output "vault_server_name" {
  description = "Name of the Vault server VM"
  value       = google_compute_instance.vault-server.name
}

output "vault_server_self_link" {
  description = "Self link of the Vault server VM"
  value       = google_compute_instance.vault-server.self_link
}

output "vm_summary" {
  description = "Summary map of all VM instances created by this module"
  value = {
    bastion_host = {
      name    = google_compute_instance.bastion-host.name
      zone    = google_compute_instance.bastion-host.zone
      machine = google_compute_instance.bastion-host.machine_type
      ip      = google_compute_instance.bastion-host.network_interface[0].network_ip
      self_link = google_compute_instance.bastion-host.self_link
    }
    gitlab_ce = {
      name    = google_compute_instance.gitlab-ce.name
      zone    = google_compute_instance.gitlab-ce.zone
      machine = google_compute_instance.gitlab-ce.machine_type
      ip      = google_compute_instance.gitlab-ce.network_interface[0].network_ip
      self_link = google_compute_instance.gitlab-ce.self_link
    }
    tfe = {
      name    = google_compute_instance.tfe.name
      zone    = google_compute_instance.tfe.zone
      machine = google_compute_instance.tfe.machine_type
      ip      = google_compute_instance.tfe.network_interface[0].network_ip
      self_link = google_compute_instance.tfe.self_link
    }
    vault_server = {
      name    = google_compute_instance.vault-server.name
      zone    = google_compute_instance.vault-server.zone
      machine = google_compute_instance.vault-server.machine_type
      ip      = google_compute_instance.vault-server.network_interface[0].network_ip
      self_link = google_compute_instance.vault-server.self_link
    }
  }
}

