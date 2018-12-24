variable "zone" {}
variable "ignition_config" {}
variable "network_name" {}
variable "subnetwork_name" {}

resource "google_compute_address" "static" {
  provider = "google-beta"
  name     = "public-web"
}

resource "google_compute_instance" "web" {
  provider     = "google-beta"
  name         = "teerace-web"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["web", "ssh"]

  boot_disk {
    initialize_params {
      image = "coreos-cloud/coreos-stable"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork_name}"

    access_config {
      nat_ip = "${google_compute_address.static.address}"
    }
  }

  metadata {
    user-data = "${var.ignition_config}"
    ssh-keys  = "core:${file("~/.ssh/id_teerace.pub")}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

output "external_ip" {
  value = "${google_compute_address.static.address}"
}

output "service_account" {
  value = "${google_compute_instance.web.service_account.0.email}"
}
