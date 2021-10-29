# Here you can reference 2 type of terraform objects :
# 1. Ressources from you provider of choice
# 2. Modules from official repositories which include modules from the following github organizations
#     - AWS: https://github.com/terraform-aws-modules
#     - GCP: https://github.com/terraform-google-modules
#     - Azure: https://github.com/Azure

data "aws_organizations_organization" "this" {}

locals {
  accounts_datasource = { for account in data.aws_organizations_organization.this.accounts :
    account.name => account
  }

  accounts_available = merge(local.accounts_datasource, aws_organizations_account.this)

  accounts_assignements_flatten = flatten([for account, value in var.accounts_assignements :
    flatten([for permission_set_name, groups in value :
      [for group in groups :
        {
          account             = local.accounts_available[account].id
          permission_set_name = permission_set_name
          permission_set_arn  = module.permission_sets.permission_sets[permission_set_name].arn
          principal_type      = "GROUP"
          principal_name      = group
        }
    ]])
  ])
}

resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name  = each.key
  email = each.value.email
}

module "permission_sets" {
  source = "git::https://github.com/cloudposse/terraform-aws-sso.git//modules/permission-sets?ref=0.6.1"

  permission_sets = var.permissions_sets
}

module "sso_account_assignments" {
  source = "git::https://github.com/cloudposse/terraform-aws-sso.git//modules/account-assignments?ref=0.6.1"

  account_assignments = local.accounts_assignements_flatten
}