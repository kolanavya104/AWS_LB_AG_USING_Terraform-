# Read the outputs from the existing configuration
data "terraform_remote_state" "outputs" {
  backend = "local"

  # Specify the path to the directory where your output.tf is located
  config = {
    path = "./terraform.tfstate"
  }
}

# Fetch the Route 53 hosted zone for the domain
data "aws_route53_zone" "primary" {
  name = data.terraform_remote_state.outputs.outputs.domain_name  # Remove .value
}

# Create an A Record that points to the ALB DNS
resource "aws_route53_record" "getterraform_com" {
  zone_id = data.aws_route53_zone.primary.zone_id

  name    = data.terraform_remote_state.outputs.outputs.domain_name  # Remove .value
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name  # Remove .value
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id  # Remove .value
    evaluate_target_health = true
  }
}
