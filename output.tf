output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "alb_zone_id" {
  value       = aws_lb.example.zone_id  # Replace 'example' with your Load Balancer resource name
  description = "The zone ID of the load balancer"
}



output "domain_name" {
  value       = "getterraform.com"
  description = "The domain name for the application"
}
