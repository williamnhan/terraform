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

variable "web_server_address_prefix" {
  type = string
}

variable "web_server_name" {
  type = string
}
variable "enviroment" {
  type = string
}
variable "web_server_count" {
  type = number
}
variable "web_server_subnet" {
  type = map
}