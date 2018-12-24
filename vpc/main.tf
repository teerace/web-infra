variable "network_name" {}
variable "region" {}

resource "google_compute_firewall" "teerace-internal" {
  name     = "teerace-internal"
  network  = "${google_compute_network.internal.name}"
  provider = "google-beta"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "teerace-ssh" {
  name     = "teerace-ssh"
  network  = "${google_compute_network.internal.name}"
  provider = "google-beta"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}

resource "google_compute_firewall" "teerace-web" {
  name     = "teerace-web"
  network  = "${google_compute_network.internal.name}"
  provider = "google-beta"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  target_tags = ["web"]
}

resource "google_compute_network" "internal" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = "false"
  provider                = "google-beta"
}

resource "google_compute_subnetwork" "internal" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.internal.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
  provider                 = "google-beta"
}

output "name" {
  value = "${google_compute_network.internal.name}"
}

output "subnetwork_name" {
  value = "${google_compute_subnetwork.internal.name}"
}

output "self_link" {
  value = "${google_compute_network.internal.self_link}"
}
