# Read the outputs from the existing configuration
data "terraform_remote_state" "outputs" {
  backend = "local"

  config = {
    path = "./terraform.tfstate"
  }
}

# Fetch the Route 53 hosted zone for the domain
data "aws_route53_zone" "primary" {
  name = data.terraform_remote_state.outputs.outputs.domain_name
}

# Check if the Route 53 record already exists
data "aws_route53_record" "existing_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name     = data.terraform_remote_state.outputs.outputs.domain_name
  type     = "A"
}

# Create an A Record that points to the ALB DNS, only if it doesn't already exist
resource "aws_route53_record" "getterraform_com" {
  count   = length(data.aws_route53_record.existing_record) == 0 ? 1 : 0

  zone_id = data.aws_route53_zone.primary.zone_id

  name    = data.terraform_remote_state.outputs.outputs.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
