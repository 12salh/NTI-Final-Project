# باراميتر SSM لسلسلة اتصال MongoDB (حدّث القيمة يدويًا)
resource "aws_ssm_parameter" "mongodb_uri" {
  name        = "/${local.name_prefix}/mongodb/uri"
  description = "MongoDB Atlas connection string"
  type        = "SecureString"
  value       = "CHANGE_ME_MONGODB_URI"
}

# سياسة قراءة الباراميتر
data "aws_iam_policy_document" "ssm_read_param" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:DescribeParameters"
    ]
    resources = [aws_ssm_parameter.mongodb_uri.arn]
  }
}

resource "aws_iam_policy" "ssm_read" {
  name   = "${local.name_prefix}-ssm-read-mongodb"
  policy = data.aws_iam_policy_document.ssm_read_param.json
}

resource "aws_iam_role_policy_attachment" "attach_ssm_read" {
  role       = aws_iam_role.app_irsa.name
  policy_arn = aws_iam_policy.ssm_read.arn
}

output "irsa_role_arn_for_app" {
  value = aws_iam_role.app_irsa.arn
}