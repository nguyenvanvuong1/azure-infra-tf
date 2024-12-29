variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "resource_group_id" {
  type = string
}
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
  type    = string
}

variable "kubernetes_version" {
  type = string
}

variable "agent_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "dns_prefix" {
  type    = string
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
  type    = string
}

variable "aks_admins_group_object_id" {
  default = "e97b6454-3fa1-499e-8e5c-5d631e9ca4d1"
  type    = string
}

variable "addons" {
  description = "Defines which addons will be activated."
  type = object({
    oms_agent                   = bool
    azure_policy                = bool
    ingress_application_gateway = bool
  })
}

variable "log_analytics_workspace_id" {
}

variable "aks_subnet" {
}

variable "aks_ingress_subnet_id" {
}

variable "environment" {
}
variable "subscription_id" {

}
variable "project" {

}
