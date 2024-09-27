# ==============================================================================
# AWS ECR Repositories for App Modules
# ==============================================================================
resource "aws_ecr_repository" "ecr_repos" {
  for_each = toset(local.app_modules)

  name = "${local.env}-${local.project}-${lower(each.key)}-repo"
  image_tag_mutability = "MUTABLE"

  tags = merge(local.common_tags, {
    Name = "${local.env}-${local.project}-${lower(each.key)}-repo"
  })
}