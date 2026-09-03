data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

locals {
  selected_zone = var.zone != "" ? var.zone : data.google_compute_zones.available.names[0]
}

resource "google_compute_instance" "bastion-host" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = local.selected_zone
  name         = "bastion-host"
  machine_type = "e2-medium"
  tags         = ["bastion", "mgmt"]

  metadata = {
    "startup-script" = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping rsync git ca-certificates curl gnupg
    if ! command -v terraform >/dev/null 2>&1; then
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
      chmod 0644 /etc/apt/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo \"$VERSION_CODENAME\") main" > /etc/apt/sources.list.d/hashicorp.list
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y terraform
    fi
    if ! command -v xrdp >/dev/null 2>&1; then
      DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-desktop-minimal xrdp
      systemctl set-default graphical.target
      systemctl enable --now xrdp
    fi
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
    EOT
  }
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
  zone         = local.selected_zone
  name         = "gitlab-ce"
  machine_type = "e2-standard-2"
  tags         = ["mgmt", "gitlab"]
  metadata = {
    "startup-script" = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    if ! command -v ping >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping
    fi
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates openssh-server gnupg
    systemctl enable --now ssh
    if ! command -v gitlab-ctl >/dev/null 2>&1; then
      curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
      EXTERNAL_URL="http://gitlab-ce.ibm-lab.internal" DEBIAN_FRONTEND=noninteractive apt-get install -y gitlab-ce
    fi
    if ! command -v gitlab-runner >/dev/null 2>&1; then
      curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
      DEBIAN_FRONTEND=noninteractive apt-get install -y gitlab-runner
    fi
    systemctl enable --now gitlab-runner
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
    EOT
  }
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20260805"
      size  = 50
    }
  }
  network_interface {
    subnetwork = var.subnet-mgmt # Replace with self link to a subnetwork in quotes
    network_ip = "10.0.1.2"
    access_config {
      network_tier = "STANDARD"
    }
  }
}


resource "google_compute_instance" "tfe" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = local.selected_zone
  name         = "tfe"
  machine_type = "e2-standard-2"
  tags         = ["mgmt"]
  metadata = {
    "startup-script" = <<-EOT
    set -eux
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    if ! command -v ping >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping
    fi
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl iputils-ping rsync git
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/ubuntu
    Suites: $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    Components: stable
    Architectures: $(dpkg --print-architecture)
    Signed-By: /etc/apt/keyrings/docker.asc
    EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
    EOT
  }
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
  zone         = local.selected_zone
  name         = "vault-server"
  machine_type = "e2-standard-2"
  tags         = ["mgmt"]
  metadata = {
    "startup-script" = <<-EOT
    # Stop on errors and print commands for easier startup-script troubleshooting.
    set -eux
    # Configure the VM timezone for the lab environment.
    ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
    echo 'Asia/Bangkok' > /etc/timezone
    # Install and start cron so the VM can shut down automatically each evening.
    if ! command -v cron >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y cron
    fi
    # Install ping for basic network connectivity checks.
    if ! command -v ping >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping
    fi
    # Add the official HashiCorp repository and install Vault if it is not installed.
    if ! command -v vault >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y gpg wget
      install -m 0755 -d /etc/apt/keyrings
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
      chmod 0644 /etc/apt/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo \"$VERSION_CODENAME\") main" > /etc/apt/sources.list.d/hashicorp.list
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y vault
    fi
    # Schedule the VM to shut down at 19:00 and ensure cron reloads the schedule.
    echo '0 19 * * * root /sbin/shutdown -h +1' > /etc/cron.d/auto-shutdown
    chmod 0644 /etc/cron.d/auto-shutdown
    systemctl enable cron >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
    EOT
  }
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

resource "google_container_cluster" "private" {
  name     = "vpcibmlab-private-gke"
  project  = var.project_id
  location = var.region

  network    = var.network
  subnetwork = var.subnet_gke

  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "private" {
  name       = "vpcibmlab-private-gke-pool"
  project    = var.project_id
  location   = google_container_cluster.private.location
  cluster    = google_container_cluster.private.name
  node_count = 3

  node_config {
    machine_type = "e2-standard-2"
    disk_type    = "pd-balanced"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}