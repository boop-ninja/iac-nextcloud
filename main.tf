

locals {
  namespace = kubernetes_namespace.i.metadata[0].name
  common_labels = {
    app     = var.app_name
    hosting = "nextcloud"
  }
  ports = {
    database = {
      name = "db"
      port = 3306
    }
    application = {
      name = "web"
      port = 80
    }
  }
  database_data = "/var/lib/mysql"
  containers = {
    database = {
      image    = var.database_image
      path     = local.database_data
      pvc_name = "${local.namespace}-dbdata-pv-claim"
      size     = "20G"
      environment = {
        MYSQL_DATABASE = "nextcloud"
        MYSQL_USER     = "nextcloud"
      }
    }
    application = {
      image    = var.app_image
      path     = "/var/www/html"
      pvc_name = "${local.namespace}-data-pv-claim"
      size     = "20G"
      environment = {
        MYSQL_ROOT_HOST = "127.0.0.1:3306"
        MYSQL_DATABASE  = "nextcloud"
        MYSQL_USER      = "nextcloud"
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
    password = var.database_password
  }
}


module "database" {
  depends_on = [kubernetes_namespace.i]
  source     = "./modules/mysql"

  labels          = local.common_labels
  namespace       = local.namespace
  database_config = local.database_config
}

module "nextcloud" {
  depends_on = [kubernetes_namespace.i]
  source     = "./modules/nextcloud"

  labels    = local.common_labels
  namespace = local.namespace
  image = var.app_image

  database_config = merge(local.database_config, {
    host = module.database.host
  })
}
