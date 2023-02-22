variable "image" {
  type        = string
  default     = "postgres:15"
  description = "description"
}

variable "name" {
  type        = string
  default     = "postgres"
  description = "description"
}


variable "namespace" {
  type        = string
  default     = "postgres"
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
