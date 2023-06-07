###ECS EC2 Worker ASG######

data "aws_ami" "aws_optimized_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = data.aws_ami.aws_optimized_ecs.id
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.aws_ecs_cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = "asg"
  vpc_zone_identifier  = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name


  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_attachment" "ecs_worker_node" {
  autoscaling_group_name = aws_autoscaling_group.failure_analysis_ecs_asg.id
  lb_target_group_arn    = aws_lb_target_group.ecs-alb-tg.arn
}

####Capacity provider#####
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.prefix}-ecs-capacity-provider"
  # cluster_name = aws_ecs_cluster.aws_ecs_cluster.name


  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.failure_analysis_ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 90
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name       = aws_ecs_cluster.aws_ecs_cluster.id
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

}