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

  accounts_assignements = {
    "orga_account" = {
      settlers = [
        "padok"
      ],
      watchers = [
        "dev"
      ]
    },
  }

  permissions_sets = [
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
