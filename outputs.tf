# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.public_server.public_ip
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.JS_VPC.id
}

# Output S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.js_bucket.bucket
}

# Output IAM Role Name
output "iam_role_name" {
  value = aws_iam_role.ec2_s3_role.name
}