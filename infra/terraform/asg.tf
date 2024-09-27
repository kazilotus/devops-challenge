resource "aws_autoscaling_group" "k3s_worker_asg" {
  desired_capacity     = local.k3s_config["desired_capacity"]
  max_size             = local.k3s_config["max_size"]
  min_size             = local.k3s_config["min_size"]
  vpc_zone_identifier  = module.vpc.private_subnet_ids

  launch_template {
    id      = aws_launch_template.k3s_worker_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.env}-${local.project}-k3s-worker"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
}