terraform {
  required_version = ">= 1.0"
}

variable "example" {
  type        = string
  default     = "Hello, Terraform!"
  description = "Example variable"
}

output "message" {
  value = var.example
}