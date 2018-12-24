variable "database_url" {}

locals {
  filesystem         = "root"
  base_path          = "/bootstrap"
  web_image          = "chaosk/teerace:master"
  acme_email         = "ksocha+teerace@ksocha.com"
  application_domain = "race.teesites.net"
}

data "template_file" "bootstrap_script" {
  template = "${file("${path.module}/bootstrap.sh.tpl")}"

  vars {
    base_path          = "${local.base_path}"
    web_image          = "${local.web_image}"
    acme_email         = "${local.acme_email}"
    application_domain = "${local.application_domain}"
    database_url       = "${var.database_url}"
  }
}

data "template_file" "bootstrap_service" {
  template = "${file("${path.module}/bootstrap.service.tpl")}"

  vars {
    base_path = "${local.base_path}"
  }
}

data "template_file" "stack" {
  template = "${file("${path.module}/stack.yml.tpl")}"

  vars {
    base_path = "${local.base_path}"
    web_image = "${local.web_image}"
  }
}

data "ignition_directory" "folder" {
  filesystem = "${local.filesystem}"
  path       = "${local.base_path}"
}

data "ignition_file" "sshd_config" {
  filesystem = "${local.filesystem}"
  path       = "/etc/ssh/sshd_config"

  content {
    content = "${file("${path.module}/sshd_config")}"
  }
}

data "ignition_file" "bootstrap-script" {
  filesystem = "${local.filesystem}"
  path       = "${local.base_path}/bootstrap.sh"

  content {
    content = "${data.template_file.bootstrap_script.rendered}"
  }
}

data "ignition_file" "web-stack" {
  filesystem = "${local.filesystem}"
  path       = "${local.base_path}/stack.yml"

  content {
    content = "${data.template_file.stack.rendered}"
  }
}

data "ignition_systemd_unit" "bootstrap" {
  name = "bootstrap.service"

  content = "${data.template_file.bootstrap_service.rendered}"
}

data "ignition_config" "bootstrap" {
  directories = [
    "${data.ignition_directory.folder.id}",
  ]

  files = [
    "${data.ignition_file.sshd_config.id}",
    "${data.ignition_file.bootstrap-script.id}",
    "${data.ignition_file.web-stack.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.bootstrap.id}",
  ]
}

output "rendered" {
  value = "${data.ignition_config.bootstrap.rendered}"
}
