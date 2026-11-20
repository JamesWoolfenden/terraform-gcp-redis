variable "cache" {
  type = object({
    name                    = string
    memory_size_gb          = number
    tier                    = string
    location_id             = string
    alternative_location_id = optional(string)
    authorized_network      = string
    redis_version           = string
    display_name            = optional(string)
    reserved_ip_range       = optional(string)
    customer_managed_key    = string
    connect_mode            = optional(string)
    replica_count           = optional(number)
    read_replicas_mode      = optional(string)
    redis_configs           = optional(map(string), {})
    maintenance_policy = optional(object({
      day     = string
      hours   = number
      minutes = number
    }))
    persistence_config = optional(object({
      persistence_mode    = optional(string, "RDB")
      rdb_snapshot_period = optional(string, "TWELVE_HOURS")
    }), {})
  })
  description = "Configuration for the Cloud Memorystore Redis instance"

  validation {
    condition     = length(var.cache.name) > 0
    error_message = "cache.name must be provided"
  }
  validation {
    condition     = var.cache.customer_managed_key != null && length(var.cache.customer_managed_key) > 0
    error_message = "cache.customer_managed_key must be a non-empty KMS CryptoKey ID"
  }
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.cache.tier)
    error_message = "cache.tier must be BASIC or STANDARD_HA"
  }
  validation {
    condition     = var.cache.tier == "STANDARD_HA" || var.cache.alternative_location_id == null
    error_message = "alternative_location_id is only valid for STANDARD_HA tier"
  }
  validation {
    condition     = contains(["REDIS_3_2", "REDIS_4_0", "REDIS_5_0", "REDIS_6_X", "REDIS_7_0", "REDIS_7_2"], var.cache.redis_version)
    error_message = "cache.redis_version must be one of REDIS_3_2, REDIS_4_0, REDIS_5_0, REDIS_6_X, REDIS_7_0, REDIS_7_2"
  }
  validation {
    condition     = var.cache.connect_mode == null || contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.cache.connect_mode)
    error_message = "cache.connect_mode must be DIRECT_PEERING or PRIVATE_SERVICE_ACCESS"
  }
  validation {
    condition     = var.cache.connect_mode != "PRIVATE_SERVICE_ACCESS" || var.cache.reserved_ip_range != null
    error_message = "reserved_ip_range must be set to the google_compute_global_address name when using PRIVATE_SERVICE_ACCESS"
  }
  validation {
    condition     = var.cache.read_replicas_mode == null || contains(["READ_REPLICAS_DISABLED", "READ_REPLICAS_ENABLED"], var.cache.read_replicas_mode)
    error_message = "cache.read_replicas_mode must be READ_REPLICAS_DISABLED or READ_REPLICAS_ENABLED"
  }
  validation {
    condition     = var.cache.read_replicas_mode != "READ_REPLICAS_ENABLED" || var.cache.replica_count != null
    error_message = "replica_count must be set when read_replicas_mode is READ_REPLICAS_ENABLED"
  }
  validation {
    condition     = var.cache.tier == "STANDARD_HA" || (var.cache.read_replicas_mode != "READ_REPLICAS_ENABLED" && coalesce(var.cache.replica_count, 0) == 0)
    error_message = "read replicas (read_replicas_mode = READ_REPLICAS_ENABLED or replica_count > 0) require tier STANDARD_HA"
  }
  validation {
    condition     = contains(["DISABLED", "RDB"], var.cache.persistence_config.persistence_mode)
    error_message = "cache.persistence_config.persistence_mode must be DISABLED or RDB"
  }
  validation {
    condition     = contains(["ONE_HOUR", "SIX_HOURS", "TWELVE_HOURS", "TWENTY_FOUR_HOURS"], var.cache.persistence_config.rdb_snapshot_period)
    error_message = "cache.persistence_config.rdb_snapshot_period must be ONE_HOUR, SIX_HOURS, TWELVE_HOURS or TWENTY_FOUR_HOURS"
  }
}

variable "region" {
  type        = string
  description = "The GCP region to deploy the Redis instance in"
  validation {
    condition     = length(var.region) > 0
    error_message = "region must be provided"
  }
}
