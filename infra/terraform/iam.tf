# ==============================================================================
# IAM Role and Instance Profile for EC2
# ==============================================================================
resource "aws_iam_role" "k3s_role" {
  name = "${local.env}-${local.project}-k3s-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "k3s_policy" {
  role = aws_iam_role.k3s_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DeleteParameter"
        ],
        Resource = "arn:aws:ssm:${local.global_config.region}:${data.aws_caller_identity.current.account_id}:parameter/k3s/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k3s_profile" {
  name = "${local.env}-${local.project}-k3s-instance-profile"
  role = aws_iam_role.k3s_role.name
}