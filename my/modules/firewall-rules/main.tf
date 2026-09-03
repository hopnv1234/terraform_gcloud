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

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gitlab"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  description = "Allow GitLab web access from the internet."
}

resource "google_compute_firewall" "bastion_internal_ingress" {
  name    = "allow-internal-services-to-bastion"
  project = var.project_id
  network = var.network_name

  direction     = "INGRESS"
  priority      = 900
  source_ranges = ["10.0.1.0/24", "10.0.4.0/24", "10.4.0.0/16", "10.5.0.0/20"]
  target_tags   = ["bastion"]

  allow {
    protocol = "all"
  }

  description = "Allow all internal protocols and ports from Vault, Terraform, GKE, and GitLab networks to the bastion."
}

resource "google_compute_firewall" "bastion_internal_egress" {
  name    = "allow-bastion-to-internal-services"
  project = var.project_id
  network = var.network_name

  direction          = "EGRESS"
  priority           = 900
  destination_ranges = ["10.0.1.0/24", "10.0.4.0/24", "10.4.0.0/16", "10.5.0.0/20"]
  target_tags        = ["bastion"]

  allow {
    protocol = "all"
  }

  description = "Allow all internal protocols and ports from the bastion to Vault, Terraform, GKE, and GitLab networks."
}
