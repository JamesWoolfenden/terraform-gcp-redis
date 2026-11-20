locals {
  # PSA is the default network path; callers can still pick DIRECT_PEERING.
  connect_mode = coalesce(var.cache.connect_mode, "PRIVATE_SERVICE_ACCESS")

  # Renders the maintenance_policy block only when a window is supplied.
  maintenance_policy = var.cache.maintenance_policy != null ? [var.cache.maintenance_policy] : []

  # The snapshot period is only meaningful (and only accepted) when RDB is on.
  rdb_snapshot_period = var.cache.persistence_config.persistence_mode == "RDB" ? var.cache.persistence_config.rdb_snapshot_period : null
}
