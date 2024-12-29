data "aws_ssm_parameter" "github_token" {
  name            = "${var.project}-${var.environment}-github-token"
  with_decryption = false
}

locals {
  argocd_components = ["controller", "dex", "redis", "server", "repoServer", "notifications", "applicationSet"]
  secrets           = base64encode(data.aws_ssm_parameter.github_token.value)
}

# helm for argo cd
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.8"

  values = [
    templatefile("${path.module}/templates/argocd/values.yaml", {
      iam_role       = aws_iam_role.argocd.arn
      telegram_token = "488971840:AAEFGkq4Dv4990OacTpn0pp4zlVhWOnZzpI"
      argocd_url     = "argocd.${var.project}.com"
    }),
    yamlencode(
      {
        for com in local.argocd_components :
        com => {
          tolerations = [
            {
              key    = "dedicated"
              value  = "ingress"
              effect = "NoSchedule"
            }
          ]
        }
      }
    )
  ]
}

resource "kubernetes_manifest" "argocd_app" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd/environments.yaml", {
    environment = var.environment
  }))

  depends_on = [
    helm_release.argocd
  ]
}