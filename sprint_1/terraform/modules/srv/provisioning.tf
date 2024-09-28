# Подключемся к сервисной srv ноде с использованием ключа через Terraform
resource "null_resource" "srv" {
  depends_on = [yandex_compute_instance.srv]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.srv.network_interface.0.nat_ip_address
  }


 # Копируем в srv ноду для установки бинарные файлы terraform и terragrunt
  provisioner "file" {
    source      = "soft/"
    destination = "/home/ubuntu"
  }

  # Копируем в srv ноду файл для установки конфига с настройкой зеркала yandex
  provisioner "file" {
    source      = "configs/"
    destination = "/home/ubuntu"
  }

  # Копируем в srv ноду скрипт для установки kubeadm, kubectl, helm, gitlab-runner
  provisioner "file" {
    source      = "scripts/"
    destination = "/home/ubuntu"
  }

  # Копируем в srv ноду ключи
  provisioner "file" {
    source      = "~/.ssh/"
    destination = "/home/ubuntu"
  }

# Копируем в srv ноду var креды для подключения к яндекс облаку
  provisioner "file" {
    source      = "modules/srv/private.variables.tf"
    destination = "/home/ubuntu/private.variables.tf"
  }

  provisioner "local-exec" {
    command = "rm modules/srv/private.variables.tf"
  }

# Устанавливаем на сервисную srv ноду terraform - делаем исполняемыми скопированные бинарные файлы. Делаем исполняемым скрипт.
# Устанавливаем на сервисную srv ноду ansible, docker, jq, kubeadm, kubectl, gitlab-runner, git.
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/install.sh",
      "sudo /home/ubuntu/install.sh",
      "sleep 5",
    ]
  }
}