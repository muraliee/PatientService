output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ecs_cluster" {
  value = aws_ecs_cluster.this.id
}
