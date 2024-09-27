# ==============================================================================
# Local Variables and Configuration
# ==============================================================================
locals {
  env    = terraform.workspace
  config = yamldecode(file("${path.module}/../config/${local.env}.yaml"))

  # Common values for tags
  owner        = local.config["global"]["owner"]
  project      = local.config["global"]["project"]
  version      = local.config["global"]["version"]
  common_tags  = {
    Environment = local.env
    Version     = local.version
    Owner       = local.owner
    Project     = local.project
  }

  # Get app modules dynamically from the YAML file
  app_modules = local.config.app.modules[*].name
  global_config = local.config["global"]
  vpc_config    = local.config["network"]["vpc"]
  k3s_config    = local.config["k3s"]
}