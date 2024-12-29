variable "location" {
  type = string
}
variable "environment" {
  type = string
}
variable "project" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}
variable "subscription_id" {
  type = string
}
