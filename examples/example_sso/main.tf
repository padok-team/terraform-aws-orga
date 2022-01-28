# Configure SSO for the organization account
# ---
# Accounts:
#  - Organization account
#
# Permission sets:
#  - Settlers
#  - Watchers
#
# Groups:
#  - Padok
#  - Dev

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "orga" {
  source = "../.."

  accounts = {}

  # Here, for exemple:
  #  - padok-cloud-factory is the name of the target account
  #  - settlers is the name of a permission set
  #  - dev and padok are groups that exist in SSO identity store (c.f. AWS SSO admin console)
  #
  # Note that here, since we do not create the account padok-cloud-factory (the accounts list above is empty)
  # The account therefore need to have already been created outside of Terraform
  account_assignements = {
    "orga_account" = {
      settlers = [
        "padok"
      ],
      watchers = [
        "dev"
      ]
    },
  }

  permission_sets = [
    {
      name               = "settlers",
      description        = "Allow Full Access to the account",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = "",
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
    {
      name               = "watchers",
      description        = "Allow ViewOnly access to the account",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = "",
      policy_attachments = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
    }
  ]
}
