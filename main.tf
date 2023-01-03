module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  comment             = "My Country Based CDN"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My Country Based CloudFront can access"
  }

  origin = {
    primary = {
      domain_name = module.origin_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
      custom_header = [
        { name: "primary", value: "True"}
      ]
    },
    failover = {
      domain_name = module.origin_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
      custom_header = [
        { name: "primary", value: "False"}
      ]
    }
  }

  origin_group = {
    my-origin-group = {
      origin_id                  = "OriginGroup"
      failover_status_codes      = [400, 403, 404, 503]
      primary_member_origin_id   = "primary"
      secondary_member_origin_id = "failover"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "OriginGroup"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    use_forwarded_values = true
    headers              = ["CloudFront-Viewer-Country"]

    lambda_function_association = {
      origin-request = {
        lambda_arn   = aws_lambda_function.lambda.qualified_arn
        include_body = false
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }
}

