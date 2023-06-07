resource "aws_security_group" "ecs_sg" {
  name        = "ecs-cluster-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.tf-vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-ecs-cluster-sg"
  }
}

### ALB SG#######

resource "aws_security_group" "ecs_alb_sg" {
  name        = "${var.prefix}-ecs-alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description      = "ECS ALB SG"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description     = "ECS ALB SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs_sg.id]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-alb-sg"
  }
}