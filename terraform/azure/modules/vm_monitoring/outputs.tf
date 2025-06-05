output "storage_account_uri" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}
