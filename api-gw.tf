resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"
}

# resource "aws_apigatewayv2_integration" "proxy" {
#   api_id                 = aws_apigatewayv2_api.http.id
#   integration_type       = "HTTP_PROXY"
#   integration_uri        = var.api_default_integration_url
#   payload_format_version = "1.0"
# }

# ربط /{proxy+}
resource "aws_apigatewayv2_route" "any_proxy" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.proxy.id}"
}

# ربط الجذر /
resource "aws_apigatewayv2_route" "any_root" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.proxy.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "prod"
  auto_deploy = true
}

output "api_gateway_invoke_url" {
  value = "${aws_apigatewayv2_api.http.api_endpoint}/${aws_apigatewayv2_stage.prod.name}/"
}

resource "aws_apigatewayv2_integration" "proxy" {
  api_id                     = aws_apigatewayv2_api.http.id
  integration_type           = "HTTP_PROXY"
  integration_uri            = var.api_default_integration_url
  integration_method         = "ANY"          # ← مهم (أو "GET" إن حبيت)
  payload_format_version     = "1.0"
  connection_type            = "INTERNET"
}