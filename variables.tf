variable "kube_host" {
  description = "Host of your kubernetes cluster"
}

variable "kube_crt" {
  default     = ""
  description = "Certificate of your kubernetes cluster"
}

variable "kube_key" {
  default     = ""
  description = "key of your kubernetes cluster"
}

variable "app_name" {
  type        = string
  default     = "nextcloud"
  description = "The name of your application"
}

variable "domain_name" {
  type        = string
  default     = "example.com"
  description = "The domain name of your nextcloud instance"
}

variable "app_image" {
  type        = string
  default     = "nextcloud:production"
  description = "The image in which you would like to use"
}

variable "database_image" {
  type        = string
  default     = "mysql:8.0-debian"
  description = "The image in which you would like to use"
}

variable "database_password" {
  type    = string
  default = "changeme"
}

output "domain" {
  value = "https://${var.domain_name}"
}

