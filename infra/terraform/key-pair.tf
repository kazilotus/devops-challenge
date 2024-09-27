# ==============================================================================
# Generate SSH Key Pair Locally and Save Private Key
# ==============================================================================

resource "tls_private_key" "k3s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "save_private_key" {
  filename = "${path.module}/k3s-key.pem"
  content  = tls_private_key.k3s_key.private_key_pem
  file_permission = "0600"  # Set permissions for the private key file
}

resource "aws_key_pair" "k3s_key_pair" {
  key_name   = "${local.env}-${local.project}-k3s-key"
  public_key = tls_private_key.k3s_key.public_key_openssh
}