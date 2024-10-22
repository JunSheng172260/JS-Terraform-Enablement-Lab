# Define the variables

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.241.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.2.0/24", "10.241.3.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = list(string)
  default     = ["10.241.4.0/24", "10.241.5.0/24", "10.241.6.0/24"]
}

variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "t3.micro"
}

variable "keypair_name" {
  description = "Name of the SSH key"
  default     = "js-keypair-terraform"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  default     = "ami-04b6019d38ea93034" # Amazon Linux 2 AMI ID
}

variable "availability_zones" {
  description = "Availability zone for the subnet"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  default     = "js-terraform-s3-bucket"
}