variable "instance_type_spot" {
  default = "t2.micro"
  type    = string
}
variable "cluster_name" {
  default     = "ecs_terraform_ec2"
  type        = string
  description = "the name of an ECS cluster"
}

variable "prefix" {
  default = "terraform-practice"
  type    = string

}

variable "region" {
  default = "us-east-1"

}

variable "vpc_cidr" {
  default = "10.0.0.0/16"

}

variable "azs" {
  type    = list(string)
  default = []

}
variable "private_subnets" {
  type    = list(string)
  default = []

}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "profile_name" {
  type = string

}

variable "include_ssm" {
  description = "Whether to include policies needed for AmazonSSM"
  type        = bool
  default     = false
}