resource "google_redis_instance" "pike" {
  name           = var.cache.name
  memory_size_gb = var.cache.memory_size_gb
  transit_encryption_mode ="SERVER_AUTHENTICATION"
  auth_enabled = true
}


