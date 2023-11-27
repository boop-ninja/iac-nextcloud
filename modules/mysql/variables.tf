variable "image" {
  type        = string
  default     = "mysql:8.0-debian"
  description = "description"
}

variable "name" {
  type        = string
  default     = "db"
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
    database = string
    username = string
    password = string
  })
  description = "description"
}

