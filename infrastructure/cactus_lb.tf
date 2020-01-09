resource "aws_alb" "cactus_alb" {
  name            = "cactus-${var.stage}-alb"
  subnets         = ["${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}", "${aws_subnet.public-subnet-3.id}"]
  security_groups = ["${aws_security_group.application_load_balancer.id}"]
}

resource "aws_alb_target_group" "cactus_front_end" {
    name        = "${var.cactus_front_name}-${var.stage}-front-end"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "${aws_vpc.vpc.id}"
    target_type = "ip"

    health_check {
        interval = 10
        port = 80
        protocol = "HTTP"
        path = "/"
        timeout = 5
        healthy_threshold = 5
        unhealthy_threshold = 3
    }
}

resource "aws_alb_target_group" "cactus_back_end" {
    name        = "${var.cactus_back_name}-${var.stage}-back-end"
    port        = 8081
    protocol    = "HTTP"
    vpc_id      = "${aws_vpc.vpc.id}"
    target_type = "ip"

    health_check {
        interval = 10
        port = 8081
        protocol = "HTTP"
        path = "/"
        timeout = 5
        healthy_threshold = 5
        unhealthy_threshold = 3
    }
}

# port exposed from the application load balancer
resource "aws_alb_listener" "cactus_front_end" {
    load_balancer_arn = "${aws_alb.cactus_alb.id}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.cactus_front_end.id}"
        type = "forward"
    }
}

# port exposed from the application load balancer
resource "aws_alb_listener" "cactus_back_end" {
    load_balancer_arn = "${aws_alb.cactus_alb.id}"
    port = "8081"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.cactus_back_end.id}"
        type = "forward"
    }
}
