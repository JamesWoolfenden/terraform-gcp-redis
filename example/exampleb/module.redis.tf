# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
#
# Private Service Access example.
#
# PSA requires two caller-managed prerequisites before the Redis instance
# can be created:
#   1. google_compute_global_address  — reserves an internal IP range in the VPC
#   2. google_service_networking_connection — establishes the VPC peering to
#      servicenetworking.googleapis.com using that range
#
# Both are VPC-level singletons: if other PSA-enabled resources (Cloud SQL,
# Memorystore Cluster, etc.) share this VPC they must reuse the same
# google_service_networking_connection. Create it once at the VPC layer, not
# per-service module call.
#
# The module is given depends_on the connection so Terraform creates the
# Redis instance only after peering is established.

resource "google_compute_global_address" "psa" {
  name          = "redis-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.authorized_network
}

resource "google_service_networking_connection" "psa" {
  network                 = var.authorized_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}

# holden:ignore:HLD_TF_026
module "redis" {
  source = "../../"

  cache = {
    name                    = "counter-psa"
    memory_size_gb          = 1
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = var.authorized_network
    redis_version           = "REDIS_7_0"
    display_name            = "Terraform Test Instance (PSA)"
    connect_mode            = "PRIVATE_SERVICE_ACCESS"
    reserved_ip_range       = google_compute_global_address.psa.name
    customer_managed_key    = google_kms_crypto_key.redis_key.id
  }
  region = "us-central1"

  # The Redis service agent must hold cloudkms.cryptoKeyEncrypterDecrypter on the CMEK key
  # before instance creation — the only link to that grant is via data.google_project.project.number,
  # which doesn't produce a Terraform dependency edge, so it must be explicit.
  depends_on = [
    google_service_networking_connection.psa,
    google_kms_crypto_key_iam_member.service,
  ]
}

resource "google_kms_key_ring" "redis_keyring" {
  name     = "redis-keyring-psa"
  location = "us-central1"
}

resource "google_kms_crypto_key" "redis_key" {
  name            = "redis-key-psa"
  key_ring        = google_kms_key_ring.redis_keyring.id
  rotation_period = "7776000s"
  lifecycle {
    prevent_destroy = true
  }
}

# Google-managed per-project service agent for Memorystore. Its identity is
# fixed by Google's naming convention (service-<project number>@cloud-redis...)
# and not user-suppliable — every caller in every project derives the same value.
resource "google_kms_crypto_key_iam_member" "service" {
  crypto_key_id = google_kms_crypto_key.redis_key.id
  member        = "serviceAccount:service-${data.google_project.this.number}@cloud-redis.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

data "google_project" "this" {
}
