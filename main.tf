# Here you can reference 2 type of terraform objects :
# 1. Ressources from you provider of choice
# 2. Modules from official repositories which include modules from the following github organizations
#     - AWS: https://github.com/terraform-aws-modules

data "aws_organizations_organization" "this" {}

# ========== LOCAL VARIABLES ========== #

locals {
  accounts_datasource = { for account in data.aws_organizations_organization.this.accounts :
    account.name => {
      id = account.id
    }
  }

  accounts_created = { for account, value in aws_organizations_account.this :
    account => {
      id = value.id
    }
  }

  accounts_available = merge(local.accounts_datasource, local.accounts_created)

  # Flatten the 'account_assignements' user-friendly input to be more module-friendly.
  # transform
  #   account_assignements = {
  #     <account_name> = {
  #       <permission_set_name> = ["<group_name1>", "<group_name2>"]
  #   }
  #
  # into
  #   [
  #     {
  #      account = <account_id>
  #      permission_set_name = <permission_set_name>
  #      permission_set_arn  = <permission_set_arn>
  #      principal_type      = "GROUP"
  #      principal_name      = <group_name1>
  #     },
  #     {
  #      account = <account_id>
  #      permission_set_name = <permission_set_name>
  #      permission_set_arn  = <permission_set_arn>
  #      principal_type      = "GROUP"
  #      principal_name      = <group_name2>
  #     }
  #   ]
  account_assignements_flatten = (
    flatten([for account_name, value in var.account_assignements :
      flatten([for permission_set_name, groups in value :
        [for group_name in groups :
          {
            account             = local.accounts_available[account_name].id
            permission_set_name = permission_set_name
            permission_set_arn  = module.permission_sets.permission_sets[permission_set_name].arn
            principal_type      = "GROUP"
            principal_name      = group_name
          }
        ]
      ])
    ])
  )

  # Terraform backend
  # tf_admin_permission_sets = [for account, value in var.accounts :
  #   {
  #     name               = "tf_admin_${account}",
  #     description        = "Allow Access to the terraform backend for ${account}",
  #     relay_state        = "",
  #     session_duration   = "",
  #     tags               = {},
  #     inline_policy      = data.aws_iam_policy_document.tf_admin[account].json
  #     policy_attachments = []
  #   }
  # ]

  tf_admin_account_assignements_flatten = (
    flatten([for account, value in var.accounts :
      flatten([for group_name in value.tf_admin_groups :
        {
          account             = local.accounts_available[account].id
          permission_set_name = "tf_admin_${account}"
          permission_set_arn  = module.permission_sets.permission_sets["tf_admin_${account}"].arn
          principal_type      = "GROUP"
          principal_name      = group_name
        }
      ])
    ])
  )
}

# ========== RESOURCES ========== #

resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name  = each.key
  email = each.value.email
}

# module "permission_sets" {
#   source = "git::https://github.com/cloudposse/terraform-aws-sso.git//modules/permission-sets?ref=0.6.1"

#   permission_sets = concat(var.permission_sets, local.tf_admin_permission_sets)
# }

module "account_assignments" {
  source = "git::https://github.com/cloudposse/terraform-aws-sso.git//modules/account-assignments?ref=0.6.1"

  account_assignments = concat(local.account_assignements_flatten, local.tf_admin_account_assignements_flatten)
}


# Terraform backend
# module "tf_backend" {
#   for_each = var.accounts
#   source   = "git::https://github.com/padok-team/terraform-aws-terraformbackend?ref=v0.1.0"

#   bucket_name         = "${each.key}-backend-terraform-state"
#   dynamodb_table_name = "${each.key}-backend-terraform-lock"
# }

# data "aws_iam_policy_document" "tf_admin" {
#   for_each = var.accounts

#   statement {
#     effect    = "Allow"
#     actions   = ["s3:ListBucket"]
#     resources = ["arn:aws:s3:::${each.key}-backend-terraform-state"]
#   }
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:GetObject", "s3:PutObject"]
#     resources = ["arn:aws:s3:::${each.key}-backend-terraform-state/*"]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "dynamodb:GetItem",
#       "dynamodb:PutItem",
#       "dynamodb:DeleteItem"
#     ]
#     resources = ["arn:aws:dynamodb:*:*:table/${each.key}-backend-terraform-lock}"]
#   }
# }
