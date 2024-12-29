variable "log_analytics_workspace_name" {
  type = string
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  type = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "environment" {
  type = string
}
variable "subscription_id" {
  type = string

}
variable "resource_group_name" {
  type    = string
  default = "uksouth"
}
