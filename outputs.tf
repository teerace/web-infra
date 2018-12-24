output "database_url" {
  value = "${module.database.url}"
}

output "vm_address" {
  value = "${module.vm.external_ip}"
}
