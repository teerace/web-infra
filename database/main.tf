variable "region" {}
variable "private_network" {}

resource "google_compute_global_address" "google-managed-services-teerace-internal" {
  provider      = "google-beta"
  name          = "google-managed-services-teerace-internal"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${var.private_network}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = "google-beta"
  network                 = "${var.private_network}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.google-managed-services-teerace-internal.name}"]
}

resource "google_sql_database_instance" "default" {
  provider         = "google-beta"
  depends_on       = ["google_service_networking_connection.private_vpc_connection"]
  name             = "teerace-postgres-${random_id.name.hex}"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = true
    }

    ip_configuration = [{
      ipv4_enabled    = false
      private_network = "${var.private_network}"
    }]

    disk_size        = 10
    disk_type        = "PD_SSD"
    replication_type = "SYNCHRONOUS"
  }
}

resource "google_sql_database" "default" {
  provider  = "google-beta"
  name      = "default"
  instance  = "${google_sql_database_instance.default.name}"
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

resource "random_id" "user-password" {
  byte_length = 8
}

resource "google_sql_user" "default" {
  provider = "google-beta"
  name     = "default"
  instance = "${google_sql_database_instance.default.name}"
  password = "${random_id.user-password.hex}"
}

resource "random_id" "name" {
  byte_length = 2
}

output "instance_name" {
  value = "${google_sql_database_instance.default.name}"
}

output "instance_address" {
  value = "${google_sql_database_instance.default.ip_address.0.ip_address}"
}

output "generated_user_password" {
  value     = "${random_id.user-password.hex}"
  sensitive = true
}

output "url" {
  value = "postgres://${google_sql_user.default.name}:${google_sql_user.default.password}@${google_sql_database_instance.default.ip_address.0.ip_address}:5432/${google_sql_database.default.name}"
}
