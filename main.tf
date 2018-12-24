terraform {
  required_version = "~> 0.10"

  backend "gcs" {
    bucket = "teerace-state-prod"
    prefix = "terraform/state"
  }
}

locals {
  project = "teerace-web"
}

provider "google-beta" {
  version = "~> 1.20"
  project = "${local.project}"
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 1.0"
}

provider "ignition" {
  version = "~> 1.0"
}

resource "random_id" "name" {
  byte_length = 2
}

module "vpc" {
  source = "./vpc"

  region       = "${var.vpc_region}"
  network_name = "${var.vpc_name}"
}

module "database" {
  source = "./database"

  region          = "${var.database_region}"
  private_network = "${module.vpc.self_link}"
}

module "ignition" {
  source = "./ignition"

  database_url = "${module.database.url}"
}

module "vm" {
  source = "./vm"

  zone            = "${var.vm_zone}"
  ignition_config = "${module.ignition.rendered}"
  network_name    = "${module.vpc.name}"
  subnetwork_name = "${module.vpc.subnetwork_name}"
}

module "storage" {
  source             = "./storage"
  region       = "${var.storage_region}"
  vm_service_account = "${module.vm.service_account}"
}
