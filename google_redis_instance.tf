resource "google_redis_instance" "pike" {
  name                    = var.cache.name
  memory_size_gb          = var.cache.memory_size_gb
  region                  = var.region
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  auth_enabled            = true
  tier                    = var.cache.tier
  location_id             = var.cache.location_id
  alternative_location_id = var.cache.alternative_location_id
  authorized_network      = var.cache.authorized_network
  redis_version           = var.cache.redis_version
  display_name            = var.cache.display_name
  reserved_ip_range       = var.cache.reserved_ip_range
  customer_managed_key    = var.cache.customer_managed_key
  labels                  = var.labels
}
