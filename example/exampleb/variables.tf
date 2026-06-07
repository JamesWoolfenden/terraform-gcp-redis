variable "authorized_network" {
  type        = string
  description = "The self_link or id of the VPC network to use for Private Service Access"
  validation {
    condition     = length(var.authorized_network) > 0
    error_message = "authorized_network must be provided"
  }
}
