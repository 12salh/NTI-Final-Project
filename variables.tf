variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "nonprod"

}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "datadog_site" {
  description = "Datadog site (datadoghq.com, datadoghq.eu, us3.datadoghq.com, ...)"
  type        = string
  default     = "datadoghq.com"
}

variable "api_default_integration_url" {
  default = "http://aa4f0cb79738443a393a739c7d0a1c07-e1ed54bd9151216a.elb.us-east-1.amazonaws.com/"
}