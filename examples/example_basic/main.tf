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

module "basic" {
  source = "../.."

  # Change email addresses with your own addresses
  #
  # Note that the addresses of AWS accounts need to be unique among all AWS accounts
  # You can however use an adress multiple with a "+" sign.
  # For exemple, all of the addresses bellow are different, and yet routed to aws@company.com
  # - aws+staging@company.com
  # - aws+preprod@company.com
  # - aws+prod@company.com
  accounts = {
    staging = {
      email = "aws+staging@company.com"
    },
    preprod = {
      email = "aws+preprod@company.com"
    },
    prod = {
      email = "aws+prod@company.com"
    }
  }

  # Here, for exemple:
  #  - staging is the name of the target account (as created above)
  #  - settlers is the name of a permission set. We are setting the permissions in permissions_set
  #  - dev and padok are groups that exist in SSO identity store (c.f. AWS SSO admin console)
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
