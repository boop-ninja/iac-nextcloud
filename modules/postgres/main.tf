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

resource "kubernetes_config_map" "i" {
  depends_on = [data.kubernetes_namespace.i]

  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = {
    POSTGRES_DB       = var.database_config.database
    POSTGRES_USER     = var.database_config.username
    POSTGRES_PASSWORD = var.database_config.password
  }
}

resource "kubernetes_deployment" "i" {
  depends_on = [kubernetes_config_map.i]

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
            name       = "${var.name}-pgdata"
            mount_path = "/var/lib/postgresql/data/pgdata"
            sub_path   = "pgdata"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.i.metadata.0.name
            }
          }

          port {
            container_port = 5432
          }
        }
        volume {
          name = "${var.name}-pgdata"
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
  }
  spec {
    selector = var.labels
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

output "cluster_ip" {
  value       = kubernetes_service.i.spec.0.cluster_ip
  sensitive   = true
  description = "description"
  depends_on  = [kubernetes_service.i]
}
