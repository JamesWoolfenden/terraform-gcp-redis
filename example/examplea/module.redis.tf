module "redis" {
  source = "../../"
  cache = {
    name           = "counter"
    memory_size_gb = 1
  }
}
