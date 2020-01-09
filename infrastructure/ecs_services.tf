resource "aws_ecs_service" "cactus_front_end" {
    name = "${var.cactus_front_name}-${var.stage}-front-end"
    cluster = "${aws_ecs_cluster.ecs_cluster.id}"
    task_definition = "${aws_ecs_task_definition.front_end.arn}"
    desired_count = 1
    launch_type = "FARGATE"
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    health_check_grace_period_seconds = 60

    network_configuration {
        security_groups = ["${aws_security_group.front_end_ecs_internal.id}"]
        subnets = ["${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}", "${aws_subnet.public-subnet-3.id}"]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = "${aws_alb_target_group.cactus_front_end.id}"
        container_name = "cactus_front_end"
        container_port = 80
    }

    depends_on = [
    ]
}

resource "aws_ecs_service" "cactus_back_end" {
    name = "${var.cactus_back_name}-${var.stage}-back-end"
    cluster = "${aws_ecs_cluster.ecs_cluster.id}"
    task_definition = "${aws_ecs_task_definition.back_end.arn}"
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        security_groups = ["${aws_security_group.back_end.id}"]
        subnets = ["${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}", "${aws_subnet.public-subnet-3.id}"]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = "${aws_alb_target_group.cactus_back_end.id}"
        container_name = "cactus_back_end"
        container_port = 8081
    }

    depends_on = [
        "aws_elasticache_cluster.cactus_back_end"
    ]
}
