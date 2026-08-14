
resource "google_compute_instance" "bastion-host" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = var.zone
  name         = "bastion-host"
  machine_type = "e2-medium"
  metadata_startup_script = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
  EOT
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20260805"
      size  = 10
    }
  }
  network_interface {
    subnetwork = var.subnet-internet # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.0.10"
    access_config {
    network_tier = "STANDARD"
  }
  }
  network_interface {
    subnetwork = var.subnet-mgmt # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.1.10"
  }
}

resource "google_compute_instance" "gitlab-ce" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = var.zone
  name         = "gitlab-ce"
  machine_type = "e2-standard-2"
  metadata_startup_script = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
  EOT
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20260805"
      size  = 50
    }
  }
  network_interface {
    subnetwork = var.subnet-mgmt # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.1.2"
  }
}


resource "google_compute_instance" "tfe" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = var.zone
  name         = "tfe"
  machine_type = "e2-standard-2"
  metadata_startup_script = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
  EOT
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20260805"
      size  = 40
      type  = "pd-ssd"
    }
  }
  network_interface {
    subnetwork = var.subnet-mgmt # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.1.3"
  }
}


resource "google_compute_instance" "vault-server" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = var.zone
  name         = "vault-server"
  machine_type = "e2-standard-2"
  metadata_startup_script = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
  EOT
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20260805"
      size  = 20
      type  = "pd-ssd"
    }
  }
  network_interface {
    subnetwork = var.subnet-mgmt # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.1.4"
  }
}