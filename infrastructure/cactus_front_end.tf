resource "aws_security_group" "application_load_balancer" {
    name = "${var.cactus_front_name}-${var.stage}-alb-web-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 80
        to_port     = 80
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
        Name = "${var.cactus_front_name}-${var.stage}-alb-web-sg"
    }
}


resource "aws_security_group" "front_end_ecs_internal" {
    name = "${var.cactus_front_name}-${var.stage}-front-end-ecs-internal-sg"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = ["${aws_security_group.application_load_balancer.id}"]
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cactus_front_name}-${var.stage}-front-end-ecs-internal-sg"
    }
}


resource "aws_ecs_task_definition" "front_end" {
  family = "${var.cactus_front_name}-${var.stage}-front-end"
  # container_definitions = "${file("cactus-components/front_end.json")}"
  network_mode = "awsvpc"
  execution_role_arn = "${aws_iam_role.ecs_task_iam_role.arn}"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024" # the valid CPU amount for 2 GB is from from 256 to 1024
  memory = "2048"
  container_definitions = <<EOF
[
  {
    "name": "cactus_front_end",
    "image": ${replace(jsonencode("${aws_ecr_repository.cactus_front_end_repository.repository_url}:${var.image_version}"), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.log_group_name}/${var.cactus_front_name}-${var.stage}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "front_end"
        }
    }
  }
]
EOF
}
