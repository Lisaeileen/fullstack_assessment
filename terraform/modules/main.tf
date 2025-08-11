resource "aws_s3_bucket" "fullstack-logs-lisa" {
  bucket        = "${var.lisa-s3-logs}-${var.lisa-env}"
  force_destroy = false

  tags = {
    Environment = var.lisa-env
  }
}

resource "aws_s3_bucket" "fullstack-site-lisa" {
  bucket        = "${var.lisa-s3-site}-${var.lisa-env}"
  force_destroy = true

  tags = {
    Environment = var.lisa-env
  }
}

resource "aws_s3_bucket_versioning" "log-versioning" {
  bucket = aws_s3_bucket.fullstack-logs-lisa.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "site-versioning" {
  bucket = aws_s3_bucket.fullstack-site-lisa.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "site-lisa-config" {
  bucket = aws_s3_bucket.fullstack-site-lisa.id

  index_document {
    suffix = "public/index.html"
  }

  error_document {
    key = "public/error.html"
  }
}

resource "aws_s3_bucket_logging" "log-site-lisa" {
  bucket = aws_s3_bucket.fullstack-site-lisa.id

  target_bucket = aws_s3_bucket.fullstack-logs-lisa.id
  target_prefix = "website-log-files/"
}

resource "aws_cloudfront_origin_access_identity" "lisa-oai" {
  comment = "OAI for private S3"
}

resource "aws_s3_bucket_policy" "allow_access_to_users" {
  bucket = aws_s3_bucket.fullstack-site-lisa.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowCloudFrontOAIRead",
        Effect   = "Allow",
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.lisa-oai.s3_canonical_user_id
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.fullstack-site-lisa.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.fullstack-site-lisa.bucket_regional_domain_name
    origin_id   = "fullstack.s3_origin_id_${var.lisa-env}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.lisa-oai.cloudfront_access_identity_path
    }
  }

resource "aws_s3_bucket_policy" "allow_access_to_users" {
  bucket = aws_s3_bucket.fullstack-site-lisa.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.fullstack-site-lisa.arn}/*"
    }]
  })
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.fullstack-site-lisa.bucket_regional_domain_name
    origin_id   = "fullstack.s3_origin_id_${var.lisa-env}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "its enabled"
  default_root_object = "public/index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "fullstack.s3_origin_id_${var.lisa-env}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.lisa-env
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
