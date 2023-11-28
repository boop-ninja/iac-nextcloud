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
      name        = "http"
      port        = 80
      target_port = "http"
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
    annotations = {
      "traefik.http.routers.nextcloud.middlewares"            = "nextcloud-redirectregex"
      "traefik.ingress.kubernetes.io/router.tls"              = true
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "acme"
    }
  }

  spec {
    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service {
              name = var.app_name
              port {
                name = "http"
              }
            }
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "nextcloud-tls"
    }
  }
}
