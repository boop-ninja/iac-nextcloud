resource "kubernetes_service" "i" {
  metadata {
    name      = var.app_name
    namespace = local.namespace
    labels    = local.common_labels
  }
  spec {
    selector         = local.common_labels
    session_affinity = "ClientIP"

    port {
      name        = local.ports.application.name
      port        = 80
      target_port = local.ports.application.port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "i" {
  depends_on = [kubernetes_namespace.i, kubernetes_service.i]

  metadata {
    name      = var.app_name
    namespace = var.app_name
    labels    = local.common_labels
  }

  spec {
    default_backend {
      service {
        name = var.app_name
        port {
          number = 80
        }
      }
    }


    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service {
              name = var.app_name
              port {
                number = 80
              }
            }
          }

          path = "/*"
        }
      }
    }

    tls {
      secret_name = kubernetes_secret.tls.metadata[0].name
    }
  }
}
