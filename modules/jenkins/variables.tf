variable "resource_group_name" {

}
variable "resource_group_location" {

}

variable "ssh_public_key" {
  type        = string
  description = "SSH key for AKS Cluster"
}
variable "environment" {
}
variable "network_interface_id" {

}
variable "subscription_id" {
}
variable "scfile" {
  type    = string
  default = "yum.bash"
}
