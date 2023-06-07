data "aws_partition" "current" {}

resource "aws_iam_role" "ecs_iam_role" {
  name = "${var.prefix}_ecs_instance_role"
  path = "/ecs/"

  # tags = "${var.prefix}-ecs-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${var.prefix}_ecs_instance_profile"
  role = aws_iam_role.ecs_iam_role.name

  # tags = "${var.prefix}-ecs-instance-profile"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs_iam_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# resource "aws_iam_role_policy_attachment" "ecs_ec2_task_role" {
#   role       = aws_iam_role.ecs_iam_role.id
#   policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
# }
resource "aws_iam_role_policy_attachment" "ecs_ec2_ecr_role" {
  role       = aws_iam_role.ecs_iam_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  count = var.include_ssm ? 1 : 0

  role       = aws_iam_role.ecs_iam_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs_iam_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
}