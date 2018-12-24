variable "vm_service_account" {}
variable "region" {}

resource "google_storage_bucket" "static" {
  provider = "google-beta"
  name     = "teerace-web-static"
  location = "${var.region}"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket" "media" {
  provider = "google-beta"
  name     = "teerace-web-media"
  location = "${var.region}"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "static-member" {
  provider = "google-beta"
  bucket   = "${google_storage_bucket.static.name}"
  role     = "roles/storage.admin"

  member = "serviceAccount:${var.vm_service_account}"
}

resource "google_storage_bucket_iam_member" "media-member" {
  provider = "google-beta"
  bucket   = "${google_storage_bucket.media.name}"
  role     = "roles/storage.admin"

  member = "serviceAccount:${var.vm_service_account}"
}

resource "google_storage_default_object_access_control" "public-static" {
  provider = "google-beta"
  bucket   = "${google_storage_bucket.static.name}"
  role     = "READER"
  entity   = "allUsers"
}

resource "google_storage_default_object_access_control" "public-media" {
  provider = "google-beta"
  bucket   = "${google_storage_bucket.media.name}"
  role     = "READER"
  entity   = "allUsers"
}
