provider "kubernetes" {
  host               = var.kube_host
  client_certificate = base64decode(var.kube_crt)
  client_key         = base64decode(var.kube_key)
  insecure           = true
}