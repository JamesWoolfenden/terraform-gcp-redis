
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "redis.instances.create",
    "redis.instances.delete",
    "redis.instances.get",
    "redis.instances.update",
    "redis.operations.get"
  ]
}
