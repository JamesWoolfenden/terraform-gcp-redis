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
  connect_mode            = local.connect_mode
  replica_count           = var.cache.replica_count
  read_replicas_mode      = var.cache.read_replicas_mode
  redis_configs           = var.cache.redis_configs

  dynamic "maintenance_policy" {
    for_each = local.maintenance_policy
    content {
      weekly_maintenance_window {
        day = maintenance_policy.value.day
        start_time {
          hours   = maintenance_policy.value.hours
          minutes = maintenance_policy.value.minutes
          seconds = 0
          nanos   = 0
        }
      }
    }
  }

  # RDB snapshots are on by default; opt out with persistence_config = { persistence_mode = "DISABLED" }.
  persistence_config {
    persistence_mode    = var.cache.persistence_config.persistence_mode
    rdb_snapshot_period = local.rdb_snapshot_period
  }
}
