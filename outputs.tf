/*output "ec2_public_ips" {
  description = "Public IPs of EC2 instances"
  value= aws_instance.my_instance[*].public_ip
}
*/

output "dev_public_ip" {
  value = module.dev_app.ec2_public_ip
}

output "stg_public_ip" {
  value = module.stg_app.ec2_public_ip
}

output "prd_public_ip" {
  value = module.prd_app.ec2_public_ip
}

output "vpc_id" {
  description = "Custom VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.my_bucket.bucket
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}