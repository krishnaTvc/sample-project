output "website_url" {
  description = "URL of the deployed static website"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the S3 bucket hosting the site"
  value       = aws_s3_bucket.website_bucket.id
}
