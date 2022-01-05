variable "path" {
  default = "/home/will/terraform/google/credentials"
}
provider "google" {
    project = "probable-skill-337219"
    region = "us-central1"
    credentials = "${file("${var.path}/secret.json")}"
}