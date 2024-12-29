output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.k8s.default_node_pool
}
