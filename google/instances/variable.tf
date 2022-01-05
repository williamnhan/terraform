variable "machine_type" {
  type = map(any)
  default = {
    "dev" = "n1-standard-1",
    "stagging" = "type-not-available-for-testing",
    "prod" = "type-not-available-for-testing"
  }
}
variable "image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
variable "servers" {
  default = ["server-1", "server-2", "server-3"]
}