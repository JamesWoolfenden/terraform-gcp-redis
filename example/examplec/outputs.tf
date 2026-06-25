output "cluster_id" {
  value       = google_redis_cluster.main.id
  description = "ID of the Redis cluster"
}
