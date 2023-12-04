output "web_loadbalancer_url" {
  value = aws_lb.ghost_alb.dns_name
}

output "web_loadbalancer_url_with_path" {
  value = "${aws_lb.ghost_alb.dns_name}/ghost"
}


output "web_loadbalancer_url_ecs" {
  value = aws_lb.ghost_alb_ecs.dns_name
}
