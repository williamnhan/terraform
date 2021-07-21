variable "web_server_location" {
  type = string
}
variable "web_server_rg" {
  type = string
}
variable "resource_prefix" {
  type = string
}
variable "web_server_address_space" {
  type = string
}
variable "web_server_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "web_server_count" {
  type = number
}
variable "web_server_subnet" {
  type = map
}
variable "terraform_script_version" {
  type = string
  validation {
    condition = can(regex("\\d\\.\\d\\.\\d", var.terraform_script_version))
    error_message = "The variable terraform_script_version must be in format x.x.x ."
  }
}
variable "admin_password" {
  type = string
}
variable "domain_name_lable" {
  type = string
}