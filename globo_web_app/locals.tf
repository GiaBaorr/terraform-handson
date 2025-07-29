# A local value assigns a name to an expression
# so you can use the name multiple times within a module instead of repeating the expression.
locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }
}