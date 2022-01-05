resource "google_compute_instance" "default" {
  count = "${length(var.servers)}"
    name = "test-${var.servers[count.index]}"
    machine_type = var.machine_type["dev"]
    zone = "us-central1-a"
    boot_disk {
      initialize_params {
        image = var.image
      }
    }
    network_interface {
      network = "default"
    }
    service_account {
      scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}
output "name" {
    value = "${google_compute_instance.default.*.name}"
}
output "machine_type" {
    value = "${google_compute_instance.default.*.machine_type}"
}
output "zone" {
    value = "${google_compute_instance.default.*.zone}"
}