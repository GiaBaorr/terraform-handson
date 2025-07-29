# Output values make information about your infrastructure available on the command line
output "aws_alb_public_dns" {
  value       = "http://${aws_lb.nginx.dns_name}"
  description = "Public DNS for ALB"
}