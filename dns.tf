# Fetch the Route 53 hosted zone for the domain
data "aws_route53_zone" "primary" {
  name = "getterraform.com"  # Your domain name
}

# Existing Route53 A record update for ALB
resource "aws_route53_record" "update_record_getterraform_com" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "getterraform.com"  # Your domain name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name  # ALB DNS name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id   # ALB Zone ID
    evaluate_target_health = true
  }

  lifecycle {
    # We are not creating anything new; only updating the existing record
    create_before_destroy = false
    prevent_destroy       = true
  }
}
