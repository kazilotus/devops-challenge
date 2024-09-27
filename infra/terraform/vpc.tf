# ==============================================================================
# VPC & Networking
# ==============================================================================
module "vpc" {
  source = "../tf-modules/vpc"

  vpc_cidr_block = local.vpc_config["cidr-block"]
  domain_name    = local.vpc_config["domain-name"]
  region         = local.config["global"]["region"]
  zones          = local.vpc_config["zones"]

  public_subnets  = local.vpc_config["subnets"]["public-blocks"]
  private_subnets = local.vpc_config["subnets"]["private-blocks"]

  public_route_table_cidr_block  = "0.0.0.0/0"
  private_route_table_cidr_block = "0.0.0.0/0"

  public_subnet_tags  = merge(tomap({ "Name" = join("-", [local.env, local.project, "public-subnet"]) }), local.common_tags)
  private_subnet_tags = merge(tomap({ "Name" = join("-", [local.env, local.project, "private-subnet"]) }), local.common_tags)

  public_route_table_tags  = merge(tomap({ "Name" = join("-", [local.env, local.project, "public"]) }), local.common_tags)
  private_route_table_tags = merge(tomap({ "Name" = join("-", [local.env, local.project, "private"]) }), local.common_tags)

  vpc_tags    = merge(tomap({ "Name" = join("-", [local.env, local.project, "vpc"]) }), local.common_tags)
  igw_tags    = merge(tomap({ "Name" = join("-", [local.env, local.project, "igw"]) }), local.common_tags)
  eip_tags    = merge(tomap({ "Name" = join("-", [local.env, local.project, "eip"]) }), local.common_tags)
  nat_gw_tags = merge(tomap({ "Name" = join("-", [local.env, local.project, "nat-gw"]) }), local.common_tags)
}