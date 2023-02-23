## This example creates a self-signed certificate for a development
## environment.
## THIS IS NOT RECOMMENDED FOR PRODUCTION SERVICES.
## See the detailed documentation of each resource for further
## security considerations and other practical tradeoffs.

resource "tls_private_key" "i" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "i" {
  # key_algorithm   = tls_private_key.i.algorithm
  private_key_pem = tls_private_key.i.private_key_pem

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [var.domain_name]

  subject {
    common_name  = var.domain_name
    organization = var.domain_name
  }

}

resource "kubernetes_secret" "tls" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = var.app_name
    namespace = local.namespace
    labels    = local.common_labels
  }

  data = {
    "tls.crt" = tls_self_signed_cert.i.cert_pem
    "tls.key" = tls_private_key.i.private_key_pem
  }

  type = "kubernetes.io/tls"
}
