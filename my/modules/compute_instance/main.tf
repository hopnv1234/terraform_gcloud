
resource "google_compute_instance" "bastion-host" {
  project      = var.project_id # Replace with your project ID in quotes
  zone         = "us-central1-b"
  name         = "bastion-host"
  machine_type = "e2-medium"
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
  zone         = "us-central1-b"
  name         = "gitlab-ce"
  machine_type = "e2-standard-2"
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
  zone         = "us-central1-b"
  name         = "tfe"
  machine_type = "e2-standard-2"
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
  zone         = "us-central1-b"
  name         = "vault-server"
  machine_type = "e2-standard-2"
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