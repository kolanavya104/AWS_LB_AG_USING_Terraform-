output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "alb_zone_id" {
  value       = aws_lb.example.zone_id  # Replace 'example' with your Load Balancer resource name
  description = "The zone ID of the load balancer"
}


# Output the EC2 host (public IP or DNS)
output "ec2_host" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
  sensitive   = true
}

# Output the EC2 username (default is ec2-user for Amazon Linux AMI)
output "ec2_username" {
  description = "Username for the EC2 instance"
  value       = "ec2-user"  # Replace with the correct username if different
  sensitive   = true
}

# Output the private key (assuming you are generating the key pair in Terraform)
output "ec2_private_key" {
  description = "Private key to access the EC2 instance"
  value       = tls_private_key.example.private_key_pem
  sensitive   = true
}

output "domain_name" {
  value       = "getterraform.com"
  description = "The domain name for the application"
}
