output "accounts_information" {
  value = [for account_name, value in var.accounts :
    {
      id                  = local.accounts_available[account_name].id
      bucket_name         = "${account_name}-backend-terraform-state"
      dynamodb_table_name = "${account_name}-backend-terraform-lock"
    }
  ]
  description = "List of accounts created with terraform backend information"
}
