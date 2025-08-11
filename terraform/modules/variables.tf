variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "lisa-env" {
  description = "environment (development, staging, production)"
  type        = string
}

variable "lisa-s3-logs" {
  description = "s3 bucket to store our site"
  type        = string
  default     = "fullstack-logs-lisa"
}

variable "lisa-s3-site" {
  description = "s3 bucket to store our site"
  type        = string
  default     = "fullstack-site-lisa"
}
