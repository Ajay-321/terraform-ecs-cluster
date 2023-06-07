resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false


  tags = {
    Environment = "${var.prefix}-alb"
  }
}

resource "aws_lb_target_group" "ecs-alb-tg" {
  name        = "${var.prefix}-ecs-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tf-vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
  }
}

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = "${aws_lb_target_group.ecs-alb-tg.arn}"
#   target_id        = "${aws_instance.test.id}"
#   port             = 80
# }
