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

# provider "xxx" {
# }

module "basic" {
  source = "../.."

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
