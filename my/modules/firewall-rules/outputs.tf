output "firewall_name" {
  description = "Name of the bastion SSH firewall rule."
  value       = google_compute_firewall.bastion_ssh_ingress.name
}
