terraform {
  required_version = ">= 1.3.0"
  required_providers {
    kubernetes = ">= 2"
  }
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
    POSTGRES_PASSWORD = var.database_config.password
  }

}


resource "kubernetes_config_map" "i" {
  depends_on = [data.kubernetes_namespace.i]
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = {
    POSTGRES_DB   = var.database_config.database
    POSTGRES_USER = var.database_config.username
  }
}

resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_secret.i,
    kubernetes_config_map.i,
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
            name       = "nextcloud-data"
            mount_path = "/var/www/html"
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
        }
        volume {
          name = "nextcloud-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.i.metadata.0.name
          }
        }
      }
    }
  }
}