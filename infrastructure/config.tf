variable "aws_region" {
   default = "eu-west-3"
}

variable "availability_zones" {
   type    = "list"
   default = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

variable "cactus_front_name" {
   default = "cactus-frontend"
}

variable "cactus_back_name" {
   default = "cactus-backend"
}

variable "stage" {
   default = "dev"
}

variable "base_cidr_block" {
   default = "10.0.0.0"
}

variable "log_group_name" {
   default = "ecs/fargate"
}

variable "image_version" {
   default = "latest"
}

variable "cactus_back_end_instance_type" {
   default = "cache.t2.small"
}
