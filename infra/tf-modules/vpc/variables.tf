variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_tags" {
  type        = map(string)
  description = "Tags to apply to the VPC"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the DHCP options set"
}

variable "domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "List of domain name servers for the DHCP options set"
}

variable "igw_tags" {
  type        = map(string)
  description = "Tags to apply to the Internet Gateway"
}

variable "eip_tags" {
  type        = map(string)
  description = "Tags to apply to the EIP"
}

variable "nat_gw_tags" {
  type        = map(string)
  description = "Tags to apply to the NAT Gateway"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
}

variable "public_subnet_tags" {
  type        = map(string)
  description = "Tags to apply to the public subnets"
}

variable "public_route_table_cidr_block" {
  type        = string
  description = "CIDR block for the public route table"
}

variable "public_route_table_tags" {
  type        = map(string)
  description = "Tags to apply to the public route table"
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags to apply to the private subnets"
}

variable "private_route_table_cidr_block" {
  type        = string
  description = "CIDR block for the private route table"
}

variable "private_route_table_tags" {
  type        = map(string)
  description = "Tags to apply to the private route table"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
}

variable "zones" {
  type        = list(string)
  description = "List of availability zones within the region"
}