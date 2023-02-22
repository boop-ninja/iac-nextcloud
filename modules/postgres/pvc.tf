
locals {
  pvc_name = "${var.namespace}-pgdata-pv-claim"
  size     = "20G"
}

resource "kubernetes_persistent_volume_claim" "i" {
  metadata {
    name      = local.pvc_name
    namespace = var.namespace
    labels    = var.labels
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = local.size
      }
    }
  }
}