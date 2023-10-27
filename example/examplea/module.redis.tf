module "redis" {
  source = "../../"
  cache = {
    name                    = "counter"
    memory_size_gb          = 1
    tier                    = "STANDARD_HA"
    location_id             = "us-central1-a"
    alternative_location_id = "us-central1-f"
    authorized_network      = data.google_compute_network.redis-network.id
    redis_version           = "REDIS_7_0"
    display_name            = "Terraform Test Instance"
    reserved_ip_range       = "192.168.0.0/29"
    customer_managed_key    = google_kms_crypto_key.redis_key.id
  }
  labels = {
    my_key    = "my_val"
    other_key = "other_val"
  }
  region = "us-central1"
}

data "google_kms_key_ring" "redis_keyring" {
  name     = "redis-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "redis_key" {
  name            = "redis-key"
  key_ring        = data.google_kms_key_ring.redis_keyring.id
  rotation_period = "7776000s"
  lifecycle {
    prevent_destroy = true
  }

}


resource "google_kms_crypto_key_iam_member" "service" {
  crypto_key_id = google_kms_crypto_key.redis_key.id
  member        = "serviceAccount:service-${data.google_project.project.number}@cloud-redis.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

data "google_compute_network" "redis-network" {
  name = "default"
}

data "google_project" "project" {
}
