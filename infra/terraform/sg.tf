# ==============================================================================
# Security Group for K3s Master and Worker Nodes
# ==============================================================================
resource "aws_security_group" "k3s_sg" {
  name        = "${local.env}-${local.project}-k3s-sg"
  description = "Security group for K3s master and worker nodes"
  vpc_id      = module.vpc.vpc_id

  # Ingress rules for K3s

  # Allow etcd traffic for HA setup (optional)
  ingress {
    description = "Allow etcd traffic (HA setup)"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow node-to-node communication on port 10250 (Kubelet metrics)
  ingress {
    description = "Allow Kubelet metrics traffic"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow node-to-node communication on port 10255 (Kubelet readonly)
  ingress {
    description = "Allow Kubelet readonly traffic"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow SSH access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Flannel VXLAN traffic (UDP port 8472)
  ingress {
    description = "Allow Flannel VXLAN traffic"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Wireguard traffic for IPv4 (UDP port 51820)
  ingress {
    description = "Allow Wireguard traffic (IPv4)"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Wireguard traffic for IPv6 (UDP port 51821)
  ingress {
    description = "Allow Wireguard traffic (IPv6)"
    from_port   = 51821
    to_port     = 51821
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Spegel distributed registry traffic (TCP port 5001)
  ingress {
    description = "Allow Spegel distributed registry traffic"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Spegel registry traffic (TCP port 6443)
  ingress {
    description = "Allow Spegel registry traffic"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow Ingress traffic (TCP port)
  ingress {
    description = "Allow Ingress traffic"
    from_port   = local.k3s_config["node_port"]
    to_port     = local.k3s_config["node_port"]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.env}-${local.project}-k3s-sg"
  })
}