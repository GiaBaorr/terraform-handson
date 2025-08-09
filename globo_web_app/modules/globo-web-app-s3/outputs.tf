# bucket object
output "web_bucket" {
  value       = aws_s3_bucket.web_bucket
  description = "The S3 bucket object created for the web application."
}

output "instance_profile" {
  value       = aws_iam_instance_profile.nginx_profile
  description = "The IAM instance profile for the Nginx instances."
}
