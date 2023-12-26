output "admin_username" {
  description = "Variable admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Auto generated admin password"
  value       = local.admin_password
}

