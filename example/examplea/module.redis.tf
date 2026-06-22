# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_GCP_146 — this example deliberately demonstrates DIRECT_PEERING
# (the supported alternative for networks without PSA infrastructure); see exampleb for PSA.
module "redis" {
  source = "../../"
  cache = {
    name                    = "counter"
    memory_size_gb          = 1
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = var.authorized_network
    redis_version           = "REDIS_7_0"
    display_name            = "Terraform Test Instance"
    # STANDARD_HA requires at least a /28 reserved range (the standby node needs the extra addresses);
    # /29 is only sufficient for BASIC tier.
    reserved_ip_range    = "192.168.0.0/28"
    customer_managed_key = google_kms_crypto_key.redis_key.id
  }
  region = "us-central1"

  # The Redis service agent must hold cloudkms.cryptoKeyEncrypterDecrypter on the CMEK key
  # before instance creation — the only link to that grant is via data.google_project.project.number,
  # which doesn't produce a Terraform dependency edge, so it must be explicit.
  depends_on = [google_kms_crypto_key_iam_member.service]
}

resource "google_kms_key_ring" "redis_keyring" {
  name     = "redis-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "redis_key" {
  name            = "redis-key"
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
