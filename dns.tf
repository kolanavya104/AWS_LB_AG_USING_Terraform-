# Fetch the Route 53 hosted zone for the domain
data "aws_route53_zone" "primary" {
  name = data.terraform_remote_state.outputs.outputs.domain_name
}

# Check if the record already exists
data "aws_route53_record" "existing" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name     = data.terraform_remote_state.outputs.outputs.domain_name
  type     = "A"

  # Use count to conditionally create
  count = length(aws_route53_record.existing) == 0 ? 1 : 0
}

# Create an A Record that points to the ALB DNS if it doesn't exist
resource "aws_route53_record" "getterraform_com" {
  count   = data.aws_route53_record.existing.count > 0 ? 0 : 1

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = data.terraform_remote_state.outputs.outputs.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
