

locals {
  namespace = kubernetes_namespace.i.metadata[0].name
  common_labels = {
    app     = var.app_name
    hosting = "nextcloud"
  }
  ports = {
    database = {
      name = "postgres"
      port = 3306
    }
    application = {
      name = "web"
      port = 80
    }
  }
  pgdata = "/var/lib/postgresql/data/pgdata"
  containers = {
    database = {
      image    = var.database_image
      path     = local.pgdata
      pvc_name = "${local.namespace}-pgdata-pv-claim"
      size     = "20G"
      environment = {

        PGDATA        = local.pgdata
        POSTGRES_DB   = "nextcloud"
        POSTGRES_USER = "nextcloud"
      }
    }
    application = {
      image    = var.app_image
      path     = "/var/www/html"
      pvc_name = "${local.namespace}-data-pv-claim"
      size     = "20G"
      environment = {
        POSTGRES_HOST = "127.0.0.1:5432"
        POSTGRES_DB   = "nextcloud"
        POSTGRES_USER = "nextcloud"
      }
    }
  }
}

resource "kubernetes_namespace" "i" {
  metadata {
    name   = var.app_name
    labels = local.common_labels
  }
}


locals {
  database_config = {
    database = "nextcloud"
    username = "nextcloud"
    password = var.postgres_password
  }
}


module "database" {
  depends_on = [kubernetes_namespace.i]
  source     = "./modules/postgres"

  labels          = local.common_labels
  namespace       = local.namespace
  database_config = local.database_config
}

module "nextcloud" {
  depends_on = [kubernetes_namespace.i]
  source     = "./modules/nextcloud"

  labels    = local.common_labels
  namespace = local.namespace
  database_config = merge(local.database_config, {
    host = module.database.cluster_ip
  })
}




# resource "kubernetes_persistent_volume_claim" "i" {
#   depends_on = [kubernetes_namespace.i]
#   for_each   = local.containers
#   metadata {
#     name      = each.value["pvc_name"]
#     namespace = local.namespace
#     labels    = local.common_labels
#   }
#   spec {
#     storage_class_name = "longhorn"
#     access_modes       = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = each.value.size
#       }
#       //      limits = {
#       //        storage = each.value.size
#       //      }
#     }
#   }
# }

# resource "kubernetes_secret" "postgres" {
#   depends_on = [kubernetes_namespace.i]
#   metadata {
#     name      = "postgres-env"
#     namespace = local.namespace
#   }

#   data = {
#     POSTGRES_PASSWORD = var.postgres_password
#   }

# }

# resource "kubernetes_deployment" "i" {
#   depends_on = [kubernetes_namespace.i]
#   metadata {
#     name      = var.app_name
#     namespace = local.namespace
#     labels    = local.common_labels
#   }
#   spec {
#     replicas = 1
#     selector {
#       match_labels = local.common_labels
#     }
#     template {
#       metadata {
#         namespace = local.namespace
#         labels    = local.common_labels
#       }
#       spec {
#         dynamic "volume" {
#           for_each = kubernetes_persistent_volume_claim.i
#           content {

#             name = volume.value.metadata[0].name
#             persistent_volume_claim {
#               claim_name = volume.value.metadata[0].name
#             }
#           }
#         }
#         dynamic "container" {
#           for_each = local.containers
#           content {
#             image = container.value["image"]
#             name  = "${var.app_name}-${container.key}"

#             resources {
#               limits = {
#                 cpu    = "0.2"
#                 memory = "512Mi"
#               }
#             }

#             dynamic "env" {
#               for_each = container.value["environment"]
#               content {
#                 name  = env.key
#                 value = env.value
#               }
#             }

#             env_from {
#               secret_ref {
#                 name = kubernetes_secret.postgres.metadata[0].name
#               }
#             }

#             port {
#               name           = local.ports[container.key]["name"]
#               container_port = local.ports[container.key]["port"]
#             }

#             volume_mount {
#               mount_path = container.value["path"]
#               name       = kubernetes_persistent_volume_claim.i[container.key].metadata[0].name
#               sub_path   = container.value["pvc_name"]
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_cron_job_v1" "i" {
#   metadata {
#     name      = "nextcloud-webcron"
#     namespace = local.namespace
#     labels    = local.common_labels
#   }
#   spec {
#     concurrency_policy            = "Replace"
#     failed_jobs_history_limit     = 5
#     schedule                      = "*/5 * * * *"
#     starting_deadline_seconds     = 10
#     successful_jobs_history_limit = 10
#     job_template {
#       metadata {
#         labels = local.common_labels
#       }
#       spec {
#         backoff_limit              = 2
#         ttl_seconds_after_finished = 10
#         template {
#           metadata {}
#           spec {
#             container {
#               name    = "apline-curl"
#               image   = "byrnedo/alpine-curl"
#               command = ["/bin/sh", "-c", "date; /usr/bin/curl https://${var.domain_name}/cron.php"]
#             }
#           }
#         }
#       }
#     }
#   }
# }
