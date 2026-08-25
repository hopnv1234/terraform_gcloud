module "vpc" {
  source                                    = "./modules/vpc"
  network_name                              = var.network_name
  auto_create_subnetworks                   = var.auto_create_subnetworks
  routing_mode                              = var.routing_mode
  project_id                                = var.project_id
  description                               = var.description
  shared_vpc_host                           = var.shared_vpc_host
  delete_default_internet_gateway_routes    = var.delete_default_internet_gateway_routes
  mtu                                       = var.mtu
  enable_ipv6_ula                           = var.enable_ipv6_ula
  internal_ipv6_range                       = var.internal_ipv6_range
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
  network_profile                           = var.network_profile
  bgp_always_compare_med                    = var.bgp_always_compare_med
  bgp_best_path_selection_mode              = var.bgp_best_path_selection_mode
  bgp_inter_region_cost                     = var.bgp_inter_region_cost
}

/******************************************
	Subnet configuration
 *****************************************/

module "subnets" {
  source       = "./modules/subnets"
  project_id   = var.project_id
  network_name = module.vpc.network_name
}

resource "google_compute_router" "nat" {
  name    = "vpcibmlab-nat-router"
  project = var.project_id
  region  = "us-central1"
  network = module.vpc.network_self_link

  depends_on = [module.subnets]
}

resource "google_compute_router_nat" "private_vms" {
  name                               = "vpcibmlab-private-vms-nat"
  project                            = var.project_id
  region                             = google_compute_router.nat.region
  router                             = google_compute_router.nat.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "subnet-mgmt"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = "subnet-gke"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

module "compute_instance" {
  source           = "./modules/compute_instance"
  project_id       = var.project_id
  network          = module.vpc.network_name
  instance_template = ""
}

module "firewall_rules" {
  source            = "./modules/firewall-rules"
  project_id        = var.project_id
  network_name      = module.vpc.network_name
  target_tag        = "mgmt"
  ssh_source_ranges = ["0.0.0.0/0"]
  ssh_port          = 22
}

resource "google_dns_managed_zone" "private_internal" {
  project  = var.project_id
  name     = "ibm-lab-internal"
  dns_name = "ibm-lab.internal."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc.network_self_link
    }
  }
}

resource "google_dns_record_set" "vm_internal_records" {
  project = var.project_id

  for_each = {
    "bastion-host" = module.compute_instance.vm_summary.bastion_host.ip
    "gitlab-ce"    = module.compute_instance.vm_summary.gitlab_ce.ip
    "tfe"          = module.compute_instance.vm_summary.tfe.ip
    "vault-server" = module.compute_instance.vm_summary.vault_server.ip
  }

  managed_zone = google_dns_managed_zone.private_internal.name
  name         = "${each.key}.${google_dns_managed_zone.private_internal.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value]
}

module "private_service_access" {
  source = "./modules/private-service-access"
  count  = var.private_service_access_config.enable_private_services_connection ? 1 : 0

  project_id    = var.project_id
  network_id    = module.vpc.network_id
  address_name  = var.private_service_access_config.address_name
  prefix_length = var.private_service_access_config.prefix_length
}

/******************************************

module "routes" {
  source            = "./modules/routes"
  project_id        = var.project_id
  network_name      = module.vpc.network_name
  routes            = var.routes
  module_depends_on = [module.subnets.subnets]
}
	Routes
 *****************************************/
/******************************************
	Firewall rules

locals {
  rules = [
    for f in var.firewall_rules : {
      name                    = f.name
      direction               = f.direction
      disabled                = lookup(f, "disabled", null)
      priority                = lookup(f, "priority", null)
      description             = lookup(f, "description", null)
      ranges                  = lookup(f, "ranges", null)
      source_tags             = lookup(f, "source_tags", null)
      source_service_accounts = lookup(f, "source_service_accounts", null)
      target_tags             = lookup(f, "target_tags", null)
      target_service_accounts = lookup(f, "target_service_accounts", null)
      allow                   = lookup(f, "allow", [])
      deny                    = lookup(f, "deny", [])
      log_config              = lookup(f, "log_config", null)
    }
  ]
}

module "firewall_rules" {
  source        = "./modules/firewall-rules"
  project_id    = var.project_id
  network_name  = module.vpc.network_name
  rules         = local.rules
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

module "private_service_access" {
  source = "./modules/private-service-access"
  count  = var.private_service_access_config.enable_private_services_connection ? 1 : 0

  project_id    = var.project_id
  network_id    = module.vpc.network_id
  address_name  = var.private_service_access_config.address_name
  prefix_length = var.private_service_access_config.prefix_length
}
 *****************************************/