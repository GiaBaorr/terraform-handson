# A local value assigns a name to an expression
# so you can use the name multiple times within a module instead of repeating the expression.
locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
    environment  = var.environment
  }

  s3_bucket_name = "${lower(local.naming_prefix)}-${random_integer.s3.result}"

  website_content = {
    index_html = "/website/index.html"
    logo_png   = "/website/Globo_logo_Vert.png"
  }

  naming_prefix = "${var.naming_prefix}-${var.environment}"
}

resource "random_integer" "s3" {
  min = 10000
  max = 99999
}