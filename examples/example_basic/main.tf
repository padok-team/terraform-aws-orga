# Create 3 account (staging, preprod, prod) and configure SSO
# ---
# Accounts:
#  - Staging
#  - Preprod
#  - Prod
#
# Permission sets:
#  - Settlers
#  - Watchers
#
# Groups:
#  - Padok (terraform state admin)
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

  accounts = {
    staging = {
      email           = "aws+staging@company.com"
      tf_admin_groups = ["padok"]
    },
    preprod = {
      email           = "aws+preprod@company.com"
      tf_admin_groups = ["padok"]
    },
    prod = {
      email           = "aws+prod@company.com"
      tf_admin_groups = ["padok"]
    }
  }

  accounts_assignements = {
    staging = {
      settlers = [
        "dev",
        "padok"
      ]
    },
    preprod = {
      settlers = [
        "padok"
      ],
      watchers = [
        "dev"
      ]
    },
    prod = {
      settlers = [
        "padok"
      ],
      watchers = [
        "dev"
      ]
    }
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
