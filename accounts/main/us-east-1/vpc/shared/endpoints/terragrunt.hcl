include "root" {
  path   = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//modules/vpc-endpoints?version=5.2.0"
}

locals {
  parent = "${get_terragrunt_dir()}/../"
  name   = "${basename(dirname(local.parent))}"
}

dependency "vpc" {
  config_path                             = "../core"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "show", "terragrunt-info", "validate"]
  mock_outputs = {
    vpc_id                  = "vpc-12345678"
    private_route_table_ids = "rt-00000001"
    public_route_table_ids  = "rt-00000002"
    intra_route_table_ids   = "rt-00000003"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  endpoints = {
    # gateway endpoints
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        dependency.vpc.outputs.private_route_table_ids,
        dependency.vpc.outputs.public_route_table_ids,
        dependency.vpc.outputs.intra_route_table_ids
      ])
      tags = { Name = "${local.name}-s3-vpc-endpoint" }
    },
    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
      route_table_ids = flatten([
        dependency.vpc.outputs.private_route_table_ids,
        dependency.vpc.outputs.public_route_table_ids,
        dependency.vpc.outputs.intra_route_table_ids
      ])
      tags = { Name = "${local.name}-dynamodb-vpc-endpoint" }
    },
  }
}
