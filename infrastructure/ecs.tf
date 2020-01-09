resource "aws_ecr_repository" "cactus_front_end_repository" {
    name = "${var.cactus_front_name}"
}

resource "aws_ecr_lifecycle_policy" "cactus_front_end_repository_lifecycly" {
  repository = "${aws_ecr_repository.cactus_front_end_repository.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the latest 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "cactus_back_end_repository" {
    name = "${var.cactus_back_name}"
}

resource "aws_ecr_lifecycle_policy" "cactus_back_end_repository_lifecycly" {
  repository = "${aws_ecr_repository.cactus_back_end_repository.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the latest 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "cactus-${var.stage}"
}

resource "aws_cloudwatch_log_group" "log_group_front_end" {
  name = "${var.log_group_name}/cactus-front-${var.stage}"
  retention_in_days = 5
}

resource "aws_cloudwatch_log_group" "log_group_back_end" {
  name = "${var.log_group_name}/cactus-back-${var.stage}"
  retention_in_days = 5
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name = "cactus-${var.stage}-ecs-task-role"
  description = "Allow ECS tasks to access AWS resources"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "ecs_task_policy" {
  name        = "cactus-${var.stage}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = "${aws_iam_role.ecs_task_iam_role.name}"
  policy_arn = "${aws_iam_policy.ecs_task_policy.arn}"
}
