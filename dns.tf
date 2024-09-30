# Fetch the Route 53 hosted zone for the domain
data "aws_route53_zone" "primary" {
  name = "getterraform.com"  # You can also use data from the remote state if needed
}

# Check for the existing Route 53 A record
data "aws_route53_record" "existing_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "getterraform.com."
  type    = "A"
}

# Create the Route 53 record only if it doesn't already exist
resource "aws_route53_record" "getterraform_com" {
  count = data.aws_route53_record.existing_record.id == "" ? 1 : 0

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "getterraform.com"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id
    evaluate_target_health = true
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}
