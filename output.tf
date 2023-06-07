output "ecs_cluster_arn" {
  value = aws_ecs_cluster.aws_ecs_cluster.id

}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.failure_analysis_ecs_asg.arn
}

output "ecs_repository_url" {
  value = aws_ecr_repository.nginx.repository_url
}

output "alb_dns_url" {
  value = aws_lb.test.dns_name

}

output "iam_role_arn" {
  value = aws_iam_role.ecs_iam_role.arn

}
output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id

}