data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}

# Service accounts
resource "yandex_iam_service_account" "admin-sf" {
  name = "admin-sf"
}

# Account rigths
resource "yandex_resourcemanager_folder_iam_member" "admin-sf" {
  folder_id = var.yandex_folder_id
  role = "admin"
  member = "serviceAccount:${yandex_iam_service_account.admin-sf.id}"
  depends_on = [
    yandex_iam_service_account.admin-sf,
  ]
}

# Access keys
resource "yandex_iam_service_account_static_access_key" "static-access-key" {
  service_account_id = yandex_iam_service_account.admin-sf.id
  depends_on = [
    yandex_iam_service_account.admin-sf,
  ]
}

# Compute instance
resource "yandex_compute_instance" "srv" {
  name        = var.name
  zone        = var.zone
  hostname    = var.name
  platform_id = "standard-v3"

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet1_id
    nat       = var.nat
  }

  scheduling_policy {
    preemptible = var.is_preemptible
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.ssh_credentials.user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file(var.ssh_credentials.pub_key)}"
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }
}

# Private_variables (fill with yours own)
data "template_file" "private_variables" {
  template = file("${path.module}/private.variables.tf.tpl")
  vars = {
    token          = var.yandex_token
    cloud_id       = var.yandex_cloud_id
    folder_id      = var.yandex_folder_id
    vpc_network_id = var.vpc_network_id
    vpc_subnet1_id = var.vpc_subnet1_id
    vpc_subnet2_id = var.vpc_subnet2_id
    vpc_subnet3_id = var.vpc_subnet3_id
  }
}

# Saving template
resource "null_resource" "update_inventory" {
  triggers = {
    template = data.template_file.private_variables.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.private_variables.rendered}' > ${path.module}/private.variables.tf"
  }
}