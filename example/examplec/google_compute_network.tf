# holden:ignore:HLD_GCP_093: Just enough to drive the redis-cluster fixture (PSC only, no instances)
# holden:ignore:HLD_GCP_094: Just enough to drive the redis-cluster fixture (PSC only, no instances)
# holden:ignore:HLD_GCP_303: Just enough to drive the redis-cluster fixture (PSC only, no instances)
resource "google_compute_network" "cluster" {
  name                    = "redis-cluster-network"
  auto_create_subnetworks = false
}
