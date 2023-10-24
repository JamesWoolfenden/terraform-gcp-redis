variable "cache" {
  type = object({
    name           = string,
    memory_size_gb = number
  })
}
