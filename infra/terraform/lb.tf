# ==============================================================================
# Network Load Balancer (NLB) for Ingress Controller (Helm Deployments)
# ==============================================================================
resource "aws_lb" "ingress_lb" {
  name               = "${local.env}-${local.project}-ingress-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnet_ids
  tags               = merge(local.common_tags, {
    Name = "${local.env}-${local.project}-ingress-nlb"
  })
}

resource "aws_lb_listener" "ingress_http_listener" {
  load_balancer_arn = aws_lb.ingress_lb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_http_tg.arn
  }
}

resource "aws_lb_target_group" "ingress_http_tg" {
  name        = "${local.env}-${local.project}-ingress-http-tg"
  port        = local.k3s_config["node_port"]
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  health_check {
    port                = local.k3s_config["node_port"]
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

# Target Group attachment for HTTP (NodePort)
resource "aws_lb_target_group_attachment" "ingress_http_tg_attachment" {
  target_group_arn = aws_lb_target_group.ingress_http_tg.arn
  target_id        = aws_instance.k3s_master.id  # Attach the master node
  port             = local.k3s_config["node_port"]
}

# Attach the Auto Scaling Group (worker nodes) to the NLB HTTP Target Group
resource "aws_autoscaling_attachment" "ingress_http_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.k3s_worker_asg.name
  lb_target_group_arn    = aws_lb_target_group.ingress_http_tg.arn
}