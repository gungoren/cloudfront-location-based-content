module "origin_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "myorigin-${random_pet.bucket_name.id}"
  acl    = "private"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cdn-cf-policy" {
  bucket = module.origin_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.my-cdn-cf-policy.json
}

data "aws_iam_policy_document" "my-cdn-cf-policy" {
  statement {
    sid = "1"
    principals {
      type        = "AWS"
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.origin_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_s3_object" "global" {
  bucket       = module.origin_bucket.s3_bucket_id
  key          = "flag.png"
  source       = "${path.module}/files/flag.png"
  content_type = "image/png"

  etag = filemd5("${path.module}/files/flag.png")
}

resource "aws_s3_object" "countries_flag" {
  for_each     = local.countries

  bucket       = module.origin_bucket.s3_bucket_id
  key          = "${each.key}/flag.png"
  source       = "${path.module}/files/flag_${each.key}.png"
  content_type = "image/png"

  etag = filemd5("${path.module}/files/flag_${each.key}.png")
}


locals {
  countries = toset(["CA", "ES", "IT", "JP", "TR", "US"])
}

