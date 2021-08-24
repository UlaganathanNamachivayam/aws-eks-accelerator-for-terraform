locals {
  tags                = tomap({ "created-by" = var.terraform_version })
  private_subnet_tags = merge(tomap({ "kubernetes.io/role/internal-elb" = "1" }), tomap({ "created-by" = var.terraform_version }))
  public_subnet_tags  = merge(tomap({ "kubernetes.io/role/elb" = "1" }), tomap({ "created-by" = var.terraform_version }))

  service_account_amp_ingest_name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-ingest-account")
  service_account_amp_query_name  = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "amp-query-account")
  amp_workspace_name              = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "EKS-Metrics-Workspace")

  image_repo = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/"

}


# ---------------------------------------------------------------------------------------------------------------------
# LABELING VPC RESOURCES
# ---------------------------------------------------------------------------------------------------------------------
module "vpc-label" {
  enabled     = var.create_vpc == true ? true : false
  source      = "../../modules/aws-resource-label"
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = "vpc"
  tags        = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC, SUBNETS AND ENDPOINTS DEPLOYED FOR FULLY PRIVATE EKS CLUSTERS
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  create_vpc = var.create_vpc
  source     = "terraform-aws-modules/vpc/aws"
  version    = "v3.2.0"
  name       = module.vpc-label.id
  cidr       = var.vpc_cidr_block
  azs        = data.aws_availability_zones.available.names
  # Private Subnets
  private_subnets     = var.enable_private_subnets ? var.private_subnets_cidr : []
  private_subnet_tags = var.enable_private_subnets ? local.private_subnet_tags : {}

  # Public Subnets
  public_subnets     = var.enable_public_subnets ? var.public_subnets_cidr : []
  public_subnet_tags = var.enable_public_subnets ? local.public_subnet_tags : {}

  enable_nat_gateway = var.enable_nat_gateway ? var.enable_nat_gateway : false
  single_nat_gateway = var.single_nat_gateway ? var.single_nat_gateway : false
  create_igw         = var.enable_public_subnets && var.create_igw ? var.create_igw : false

  enable_vpn_gateway              = false
  create_egress_only_igw          = false
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enabling Custom Domain name servers
  //  enable_dhcp_options              = true
  //  dhcp_options_domain_name         = "service.consul"
  //  dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_max_aggregation_interval    = 60

  tags = local.tags

  manage_default_security_group = true

  default_security_group_name = "${module.vpc-label.id}-endpoint-secgrp"
  default_security_group_ingress = [
    {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = var.vpc_cidr_block
    }]
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }]

}
################################################################################
# VPC Endpoints Module
################################################################################
module "endpoints_interface" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "v3.2.0"

  create = var.create_vpc_endpoints
  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids])
      tags = { Name = "s3-vpc-Gateway" }
    },
    /*
    dynamodb = {
      service = "dynamodb"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids])
      policy = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags = { Name = "dynamodb-vpc-endpoint" }
    },
    */
  }
}

module "vpc_endpoints_gateway" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "v3.2.0"

  create = var.create_vpc_endpoints

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]
  subnet_ids         = module.vpc.private_subnets

  endpoints = {
    aps-workspaces = {
      service             = "aps-workspaces"
      private_dns_enabled = true
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
    },
    autoscaling = {
      service             = "autoscaling"
      private_dns_enabled = true
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
    },
    elasticloadbalancing = {
      service             = "elasticloadbalancing"
      private_dns_enabled = true
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
    },
    /*    elasticfilesystem = {
          service             = "elasticfilesystem"
          private_dns_enabled = true
        },
        ssmmessages = {
          service             = "ssmmessages"
          private_dns_enabled = true
        },
        lambda = {
          service             = "lambda"
          private_dns_enabled = true
        },
        ecs = {
          service             = "ecs"
          private_dns_enabled = true
        },
        ecs_telemetry = {
          service             = "ecs-telemetry"
          private_dns_enabled = true
        },
        codedeploy = {
          service             = "codedeploy"
          private_dns_enabled = true
        },
        codedeploy_commands_secure = {
          service             = "codedeploy-commands-secure"
          private_dns_enabled = true
        },*/
  }

  tags = merge(local.tags, {
    Project  = "EKS"
    Endpoint = "true"
  })
}
