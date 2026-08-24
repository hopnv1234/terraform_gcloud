resource "google_compute_firewall" "bastion_ssh_ingress" {
  name    = "allow-bastion-ssh-from-internet"
  project = var.project_id
  network = var.network_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = var.ssh_source_ranges

  target_tags = [var.target_tag]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  description = "Allow SSH access from internet to the bastion host only."
}

resource "google_compute_firewall" "internal_icmp_ingress" {
  name    = "allow-internal-icmp"
  project = var.project_id
  network = var.network_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["10.0.1.0/24"]
  target_tags   = [var.target_tag]

  allow {
    protocol = "icmp"
  }

  description = "Allow ping between management VMs."
}

resource "google_compute_firewall" "gitlab_web_ingress" {
  name    = "allow-gitlab-web-from-management"
  project = var.project_id
  network = var.network_name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["gitlab"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  description = "Allow GitLab web access from the management subnet."
}
