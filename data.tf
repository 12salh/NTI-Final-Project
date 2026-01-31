data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state         = "available"
  exclude_names = ["us-east-1-nyc-2a", "us-east-1-foe-wlz-1a"]
}