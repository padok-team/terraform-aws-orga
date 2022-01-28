# AWS Organisation Terraform module

Terraform module which creates **Child Accounts** and **SSO permissions assignements** resources on **AWS**. It will also create **Terraform Backend** for Child Accounts. This module is an abstraction of the [terraform-aws-sso](https://github.com/cloudposse/terraform-aws-sso) by [@cloudposse](https://github.com/cloudposse).

## User Stories for this module

- AAOps I can create child AWS account with terraform backend for my organization
- AAOps I can give my users rights to all the accounts of my organization

## Prerequisites

- An organization AWS account
- AWS SSO enabled (in the right region)
- In AWS SSO settings, MFA configured
- AWS SSO Groups created

## Usage

```hcl
module "orga" {
  source = "https://github.com/padok-team/terraform-aws-orga"

  accounts = {
    staging = {
      email           = "aws+staging@company.com"
      tf_admin_groups = ["padok"]
    },
    prod = {
      email           = "aws+prod@company.com"
      tf_admin_groups = ["padok"]
    }
  }

  account_assignements = {
    stagging = {
      settlers = ["padok", "dev"],
    },
    prod = {
      settlers = ["padok"],
      watchers = ["dev"]
    }
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
```

**Warning** : You need to make the terraform apply in two step.
```
# First create only the accounts
terraform apply -target module.orga.aws_organizations_account.this

# Then everythings else
terrform apply
```

## Examples

- [AAOps I give my users rights to AWS organization accounts with SSO](examples/example_sso/main.tf)
- [AAOps I create 3 AWS account (staging, preprod, prod) and give my users rights to them with SSO](examples/example_basic/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_permission_sets"></a> [permission\_sets](#module\_permission\_sets) | git::https://github.com/cloudposse/terraform-aws-sso.git//modules/permission-sets | 0.6.1 |
| <a name="module_sso_account_assignments"></a> [sso\_account\_assignments](#module\_sso\_account\_assignments) | git::https://github.com/cloudposse/terraform-aws-sso.git//modules/account-assignments | 0.6.1 |
| <a name="module_tf_backends"></a> [tf\_backends](#module\_tf\_backends) | git::https://github.com/padok-team/terraform-aws-terraformbackend | feat/init_module |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | List of accounts to be created | <pre>map(object({<br>    email = string<br>    tf_admin_groups = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_accounts_assignements"></a> [accounts\_assignements](#input\_accounts\_assignements) | List of assignement between an account within the organization, a permission set and a group. | `map(map(list(string)))` | n/a | yes |
| <a name="input_permissions_sets"></a> [permissions\_sets](#input\_permissions\_sets) | List of available permission sets | <pre>list(object({<br>    name               = string<br>    description        = string<br>    relay_state        = string<br>    session_duration   = string<br>    tags               = map(string)<br>    inline_policy      = string<br>    policy_attachments = list(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_accounts_created"></a> [accounts\_created](#output\_accounts\_created) | List of accounts created with terraform backend information |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
