variable "image" {
  type        = string
  default     = "nextcloud:stable"
  description = "description"
}

variable "name" {
  type        = string
  default     = "nextcloud"
  description = "description"
}


variable "namespace" {
  type        = string
  default     = "nextcloud"
  description = "description"
}


variable "labels" {
  type        = map(any)
  default     = {}
  description = "description"
}

variable "database_config" {
  sensitive = true
  type = object({
    host     = string
    database = string
    username = string
    password = string
  })
  description = "description"
}

variable "trusted_domain" {
  type        = string
  default     = "localhost"
  description = "description"
}