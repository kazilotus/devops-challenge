# ==============================================================================
# EC2 Instance for K3s Master Node
# ==============================================================================
resource "aws_instance" "k3s_master" {
  ami                      = data.aws_ami.ubuntu.id
  subnet_id                = module.vpc.private_subnet_ids[0]

  launch_template {
    id      = aws_launch_template.k3s_master_launch_template.id
    version = aws_launch_template.k3s_master_launch_template.latest_version
  }

  tags = merge(local.common_tags, {
    Name = "${local.env}-${local.project}-k3s-master"
  })
}