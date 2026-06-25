# Standalone fixture, not wrapped by the module root — google_redis_cluster
# is a distinct resource family from google_redis_instance (HLD_GCP_195,
# HLD_GCP_196 target the cluster resource specifically).
resource "google_redis_cluster" "main" {
  name                    = "counter-cluster"
  shard_count             = 3
  region                  = "us-central1"
  authorization_mode      = "AUTH_MODE_IAM_AUTH"
  transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION"

  psc_configs {
    network = google_compute_network.cluster.id
  }
}
