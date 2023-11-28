resource "kubernetes_cron_job" "i" {
  metadata {
    name = "nextcloud-webcron"
    namespace = data.kubernetes_namespace.i.metadata[0].name
  }

  spec {
    schedule = "*/5 * * * *"
    successful_jobs_history_limit = 0
    failed_jobs_history_limit = 1
    concurrency_policy = "Forbid"
    job_template {
      spec {
        template {
          metadata {
            labels = {
              app = "nextcloud-webcron"
            }
          }
          spec {
            container {
              image = "quay.io/curl/curl:latest"
              name = "nextcloud-webcron"
              command = ["curl", "-X", "GET", "https://${var.trusted_domain}/cron.php"]
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}