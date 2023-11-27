terraform {
  required_version = ">= 1.3.0"
  required_providers {
    kubernetes = ">= 2"
  }
}

locals {
  port = 5432
}

data "kubernetes_namespace" "i" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "i" {
  depends_on = [data.kubernetes_namespace.i]
  metadata {
    name      = "${var.name}-db-pass"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    MYSQL_ROOT_PASSWORD = var.database_config.password
  }

}
resource "kubernetes_config_map" "i" {
  depends_on = [data.kubernetes_namespace.i]

  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = {
    MYSQL_DATABASE   = var.database_config.database
    MYSQL_USER = var.database_config.username
  }
}

resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_secret.i,
    kubernetes_config_map.i,
    data.kubernetes_namespace.i,
  ]

  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
  }

  spec {
    selector {
      match_labels = var.labels
    }

    template {
      metadata {
        labels = var.labels
      }
      spec {
        container {

          image = var.image
          name  = var.name
          volume_mount {
            name       = "${var.name}-dbdata"
            mount_path = "/var/lib/mysql"
            sub_path   = kubernetes_persistent_volume_claim.i.metadata.0.name
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.i.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.i.metadata.0.name
            }
          }

          port {
            name           = "db"
            container_port = local.port
          }
        }
        volume {
          name = "${var.name}-dbdata"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.i.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "i" {
  depends_on = [kubernetes_deployment.i]

  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
  }
  spec {
    selector = var.labels
    port {
      port        = local.port
      target_port = "db"
    }
  }
}

output "host" {
  value       = "${kubernetes_service.i.metadata[0].name}.${data.kubernetes_namespace.i.metadata[0].name}.svc.cluster.local:${local.port}"
  description = "description"
  depends_on  = [kubernetes_service.i]
}
