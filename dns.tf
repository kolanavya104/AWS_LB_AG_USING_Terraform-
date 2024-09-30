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

# Create the Route 53 record if it doesn't already exist
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
    create_before_destroy = true  # Optional: Prevent resource destruction before re-creation
  }

  # Avoid creating a new record if it already exists
  # The `prevent_destroy` will prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# A local-exec command that can be run to manually check for the record
resource "null_resource" "check_existing_record" {
  provisioner "local-exec" {
    command = "aws route53 list-resource-record-sets --hosted-zone-id ${data.aws_route53_zone.primary.zone_id} --query 'ResourceRecordSets[?Name==`${data.terraform_remote_state.outputs.outputs.domain_name}.`] | [0]'"
    interpreter = ["bash", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
