resource "aws_security_group" "application_load_balancer_back_end" {
    name = "${var.cactus_back_name}-${var.stage}-alb-back-end-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 8081
        to_port     = 8081
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cactus_back_name}-${var.stage}-alb-back-end-sg"
    }
}

resource "aws_security_group" "back_end_ecs_internal" {
    name = "${var.cactus_back_name}-${var.stage}-back-end-ecs-internal-sg"
    description = "cactus back-end"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 8081
        to_port     = 8081
        protocol    = "tcp"
        security_groups = ["${aws_security_group.application_load_balancer_back_end.id}"]
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cactus_back_name}-${var.stage}-back-end-ecs-internal-sg"
    }
}

resource "aws_ecs_task_definition" "back_end" {
  family = "${var.cactus_back_name}-${var.stage}-back-end"
  network_mode = "awsvpc"
  execution_role_arn = "${aws_iam_role.ecs_task_iam_role.arn}"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024" # the valid CPU amount for 2 GB is from from 256 to 1024
  memory = "2048"
  container_definitions = <<EOF
[
  {
    "name": "cactus_back_end",
    "image": ${replace(jsonencode("${aws_ecr_repository.cactus_back_end_repository.repository_url}:${var.image_version}"), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")} ,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8081,
        "hostPort": 8081
      }
    ],
    "environment": [
      {
        "name": "REDIS_HOST",
        "value": "cactus-backend-dev.pbat74.0001.euw3.cache.amazonaws.com"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.log_group_name}/${var.cactus_back_name}-${var.stage}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "back-end"
        }
    }
  }
]
EOF
}
