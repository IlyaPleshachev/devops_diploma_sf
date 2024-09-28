# Переменная токена подключения к облаку яндекс
variable "yandex_cloud_token" {
  description = "Default cloud token in yandex cloud"
  type        = string
  default     = "${token}"
  sensitive   = true
}

# Переменная id облака, для развертки ВМ
variable "yandex_cloud_id" {
  description = "Default cloud ID in yandex cloud"
  type        = string
  default     = "${cloud_id}"
}

# Переменная id папки, для развертки ВМ
variable "yandex_folder_id" {
  description = "Default folder ID in yandex cloud"
  type        = string
  default     = "${folder_id}"
}

# Переменная id сети
variable "vpc_network_id" {
  description = "VPC network id"
  type        = string
  default     = "${vpc_network_id}"
}

# Переменная id подсети
variable "vpc_subnet1_id" {
  description = "VPC subnet 1 id"
  type        = string
  default     = "${vpc_subnet1_id}"
}

# Переменная id подсети 2
variable "vpc_subnet2_id" {
  description = "VPC subnet 2 id"
  type        = string
  default     = "${vpc_subnet2_id}"
}

# Переменная id подсети 3
variable "vpc_subnet3_id" {
  description = "VPC subnet 3 id"
  type        = string
  default     = "${vpc_subnet3_id}"
}