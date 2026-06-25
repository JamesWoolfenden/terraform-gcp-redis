resource "google_compute_network" "cluster" {
  name                    = "redis-cluster-network"
  auto_create_subnetworks = false
}
