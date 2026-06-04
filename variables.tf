variable "aws_region" {
    description = "The AWS region for infrastructure"
    type = string 
    default = "ap-south-1"
}

variable "ami_id" {
      description = "Ubuntu AMI ID for EC2"
      type = string
      default = "ami-07a00cf47dbbc844c"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

