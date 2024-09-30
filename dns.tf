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

# Use a local value to check if the record already exists
resource "aws_route53_record" "getterraform_com" {
  zone_id = data.aws_route53_zone.primary.zone_id

  name    = data.terraform_remote_state.outputs.outputs.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id
    evaluate_target_health = true
  }

  lifecycle {
    prevent_destroy = true  # Optional: Prevent the resource from being accidentally destroyed
  }
}

# Create a null resource to check if the Route 53 record already exists
resource "null_resource" "check_existing_record" {
  provisioner "local-exec" {
    command = "aws route53 list-resource-record-sets --hosted-zone-id ${data.aws_route53_zone.primary.zone_id} --query 'ResourceRecordSets[?Name==`${data.terraform_remote_state.outputs.outputs.domain_name}.`] | [0]'"
    interpreter = ["bash", "-c"]
    on_failure = continue
  }

  triggers = {
    record_exists = aws_route53_record.getterraform_com.id
  }
}

# Only create the Route 53 record if it does not already exist
resource "aws_route53_record" "conditional" {
  count = length(null_resource.check_existing_record.triggers.record_exists) == 0 ? 1 : 0

  zone_id = data.aws_route53_zone.primary.zone_id

  name    = data.terraform_remote_state.outputs.outputs.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.outputs.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.outputs.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
