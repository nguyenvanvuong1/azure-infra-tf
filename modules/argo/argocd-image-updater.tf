# manifest secret for argo cd
# resource "kubernetes_manifest" "argocd_secret" {
#   manifest = yamldecode(templatefile("${path.module}/templates/argocd/secret.yaml", {
#     GITHUB_URL   = base64encode("https://github.com/nguyenvanvuong1/azure-gitops")
#     GITHUB_TOKEN = var.github_token
#     NAMESPACE    = "argocd"
#   }))
#   depends_on = [
#     helm_release.argocd,
#   ]
# }

# helm for argo cd image updater
resource "helm_release" "argocd_image_updater" {
  name             = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.9.1"

  depends_on = [
    helm_release.argocd,
  ]

  values = [
    templatefile("${path.module}/templates/argocd/image-updater-values.yaml", {

    })
  ]
}
