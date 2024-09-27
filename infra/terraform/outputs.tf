output "ingress_lb_dns" {
  description = "DNS name of the ingress Network Load Balancer"
  value       = aws_lb.ingress_lb.dns_name
}