output "redis" {
  value       = module.redis
  description = "The Redis instance resource"
  sensitive   = true
}
