variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-1"
}

variable "vpc_cidr" {
	description = "CIDR block for the VPC"
	type = string
	default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "CIDR block for the public subnet"
	type = list(string)
	default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
	description = "CIDR block for the private subnet"
	type = list(string)
	default = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "key_name" {
    description = "EC2 key pair name for SSH access"
    type        = string
}

variable "my_ip" {
	description = "Your public IP for SSH access (e.g., 203.0.113.50/32)"
	type = string
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t3.micro"
}