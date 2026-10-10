# Generate random unique suffix for S3 bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. Create S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket        = "${var.app_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# 2. Configure S3 Bucket Website Hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# 3. Disable Public Access Block to allow Public Website Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Configure Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 5. Add Bucket Policy allowing Public Read Access for website contents
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  depends_on = [
    aws_s3_bucket_public_access_block.public_access,
    aws_s3_bucket_ownership_controls.ownership
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# 5. Upload index.html to S3 Bucket
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}
