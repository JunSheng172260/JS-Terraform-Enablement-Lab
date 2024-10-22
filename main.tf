# main.tf for provisioning resource 

# Create VPC
resource "aws_vpc" "JS_VPC" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "js-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "JS_IGW" {
  vpc_id = aws_vpc.JS_VPC.id

  tags = {
    Name = "main-igw"
  }
}

# Create Route Table for public subnets
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.JS_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.JS_IGW.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Create Subnets and associate with route table (public subnets)
resource "aws_subnet" "public_subnets" {
  count = length(var.subnet_cidr)

  vpc_id                  = aws_vpc.JS_VPC.id
  cidr_block              = var.subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidr)

  vpc_id                  = aws_vpc.JS_VPC.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Associate the public route table with each public subnet
resource "aws_route_table_association" "public_route_association" {
  count = length(var.subnet_cidr)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route.id
}

# Create Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.JS_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["121.122.113.166/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


resource "aws_s3_bucket" "js_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "js-tf-s3-bucket"
  }
}

# Create an IAM Role for EC2 with S3 access
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a policy to the role allowing EC2 instances to access S3
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2_s3_access_policy"
  role = aws_iam_role.ec2_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.js_bucket.arn,
          "${aws_s3_bucket.js_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the AmazonSSMManagedInstanceCore policy to allow EC2 to be managed by SSM
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ec2_s3_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_instance_profile"
  role = aws_iam_role.ec2_s3_role.name
}


# Create EC2 Instance in the first public subnet
resource "aws_instance" "public_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  key_name               = var.keypair_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "public-server"
  }
  user_data = <<-EOF
   #!/bin/bash
   # Update the instance
   yum update -y

   # Install Nginx Server
   sudo dnf install nginx -y

   # Start Nginx Web Server
   sudo systemctl start nginx
   sudo systemctl enable nginx
   EOF

}