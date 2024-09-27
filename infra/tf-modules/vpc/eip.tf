resource "aws_eip" "main" {
  domain = "vpc"
  tags   = var.eip_tags

  lifecycle {
    prevent_destroy = true
  }
}
