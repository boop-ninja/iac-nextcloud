terraform {
  required_version = ">= 1.3.0"
  required_providers {
    kubernetes = ">= 2"
  }
}

resource "kubernetes_config_map" "i" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = var.database_config
}

resource "kubernetes_deployment" "i" {
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