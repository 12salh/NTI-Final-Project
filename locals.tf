locals {
  name_prefix  = "nti-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"
}