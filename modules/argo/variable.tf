### define variable su dung
variable "project" {
  type    = string
  default = "vuongnvpractice"
}
variable "environment" {
  type    = string
  default = "vuongnv"
}
variable "cluster_endpoint" {
  type = string
}
variable "cluster_ca_certificate" {
  type = string
}
variable "client_key" {
  type = string
}
variable "client_certificate" {
  type = string
}
variable "subscription_id" {

}
variable "github_token" {
  
}