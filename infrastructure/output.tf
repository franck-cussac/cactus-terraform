output "cactus_front_end_endpoint" {
  value = "${aws_alb.cactus_alb.dns_name}"
}
