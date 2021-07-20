data "azurerm_key_vault" "key_vault" {
  name = "terraform-will"
  resource_group_name = "remote-state"
}

data "azurerm_key_vault_secret" "vm_password" {
  name = "vm-password"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}