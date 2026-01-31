data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# متغيرات
variable "app_namespace" {
  type    = string
  default = "app"
}
variable "app_service_account" {
  type    = string
  default = "app-sa"
}

resource "kubernetes_namespace" "app" {
  metadata { name = var.app_namespace }
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.app_namespace}:${var.app_service_account}"]
    }
  }
}

resource "aws_iam_role" "app_irsa" {
  name               = "${local.name_prefix}-irsa-app"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

# هنضيف سياسة القراءة من SSM بعد شوية (قسم SSM أدناه)