variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t2.micro"
}
