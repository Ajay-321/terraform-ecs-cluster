###ECS Cluster ############
resource "aws_ecs_cluster" "aws_ecs_cluster" {
  name = "my-tf-ecs-cluster"

}

###ECS Task definition##########
resource "aws_ecs_task_definition" "task_definition" {
  family             = "${var.prefix}-ecs-task"
  execution_role_arn = aws_iam_role.ecs_iam_role.arn
  memory             = 1024
  cpu                = 512
  network_mode       = "bridge"
  container_definitions = jsonencode([
    {
      name      = "mongo"
      image     = "${aws_ecr_repository.nginx.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  tags = {
    Name = "${var.prefix}-ecs-task-definition"
  }
}

#################ECS Service #############
resource "aws_ecs_service" "nginx" {
  name            = "${var.prefix}-ecs-service"
  cluster         = aws_ecs_cluster.aws_ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  #for awsvpc network_mode
  # network_configuration {
  #   subnets = flatten([aws_subnet.private_subnets[*].id],)
  # }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
    container_name   = "mongo"
    container_port   = 80
  }
}
