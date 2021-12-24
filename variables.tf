variable "accounts" {
  description = "List of accounts to be created"
  type = map(object({
    email = string
  }))
}

variable "accounts_assignements" {
  description = "List of assignement between an account within the organization, a permission set and a group."
  type        = map(map(list(string)))
}

variable "permissions_sets" {
  description = "List of available permission sets"
  type = list(object({
    name               = string
    description        = string
    relay_state        = string
    session_duration   = string
    tags               = map(string)
    inline_policy      = string
    policy_attachments = list(string)
  }))
}
