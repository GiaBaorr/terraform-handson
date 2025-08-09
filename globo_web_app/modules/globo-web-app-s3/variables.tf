# bucket_name
variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
}

# elb_service_account_arn

variable "elb_service_account_arn" {
  description = "The ARN of the service account for the ELB."
  type        = string
}

# common_tags
variable "common_tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
