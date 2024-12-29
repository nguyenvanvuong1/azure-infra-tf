variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics Workspace Name"
}

variable "location" {
  type        = string
  description = "Location of Resources"
}

variable "kubernetes_version" {
  type        = string
  description = "AKS K8s Version"
}

variable "agent_count" {
  type        = string
  description = "AKS Agent Count"
}

variable "vm_size" {
  type        = string
  description = "AKS VM Size"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH key for AKS Cluster"
}
variable "subscription_id" {
  type = string
}

variable "project" {
  type = string
}
variable "github_token" {
  type      = string
  sensitive = true
}
variable "scfile" {
  type = string
}
variable "jenkins_network_address_space" {
  type = string
}
variable "jenkins_subnet_address" {
  type = string
}
variable "aks_network_address_space" {
  type = string
}
variable "aks_subnet_address" {
  type = string
}
variable "aks_ingress_subnet_address" {
  type = string
}