variable "cache" {
  type = object({
    name                    = string
    memory_size_gb          = number
    tier                    = string
    location_id             = string
    alternative_location_id = string
    authorized_network      = string
    redis_version           = string
    display_name            = string
    reserved_ip_range       = string
    customer_managed_key    = string
  })
}

variable "labels" {
  type = map(any)
}

variable "region" {
  type = string
}
