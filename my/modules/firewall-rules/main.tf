resource "google_compute_firewall" "bastion_ssh_ingress" {
  name    = "allow-bastion-ssh-from-internet"
  project = var.project_id
  network = var.network_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = var.ssh_source_ranges

  target_tags = [var.bastion_tag]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  description = "Allow SSH access from internet to the bastion host only."
}
