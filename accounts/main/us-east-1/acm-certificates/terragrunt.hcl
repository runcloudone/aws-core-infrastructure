include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/acm/aws//wrappers?version=5.0.0"
}

dependency "route53_zones" {
  config_path                             = "../../global/route53/zones"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "show", "terragrunt-info", "validate"]
  mock_outputs = {
    route53_zone_name = {
      public = "example.com"
    }
    route53_zone_zone_id = {
      public = "Z3P5QSUBK4POTI"
    }
  }
}

inputs = {
  items = {
    wildcard = {
      domain_name = dependency.route53_zones.outputs.route53_zone_name.public
      zone_id     = dependency.route53_zones.outputs.route53_zone_zone_id.public

      subject_alternative_names = [
        "*.${dependency.route53_zones.outputs.route53_zone_name.public}"
      ]

      validation_method   = "DNS"
      wait_for_validation = true
    }
  }
}