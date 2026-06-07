output "redis" {
  value       = google_redis_instance.pike
  description = "The full Redis instance resource"
  sensitive   = true
}

output "host" {
  value       = google_redis_instance.pike.host
  description = "The IP address of the Redis instance"
}

output "port" {
  value       = google_redis_instance.pike.port
  description = "The port number of the Redis instance"
}

output "id" {
  value       = google_redis_instance.pike.id
  description = "The resource ID of the Redis instance"
}

output "auth_string" {
  value       = google_redis_instance.pike.auth_string
  description = "The AUTH string for the Redis instance"
  sensitive   = true
}

output "server_ca_certs" {
  value       = google_redis_instance.pike.server_ca_certs
  description = "CA certificates for TLS verification"
  sensitive   = true
}
