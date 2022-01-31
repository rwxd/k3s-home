provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb"
  create_namespace = true

  set {
    name  = "configInline.address-pools[0].name"
    value = "default"
    type  = "string"
  }

  set {
    name  = "configInline.address-pools[0].protocol"
    value = "layer2"
    type  = "string"
  }

  set {
    name  = "configInline.address-pools[0].addresses[0]"
    value = "192.168.3.200-192.168.3.250"
    type  = "string"
  }
}


#resource "helm_release" "project-contour" {
#  name             = "project-contour"
#  repository       = "https://charts.bitnami.com/bitnami"
#  chart            = "contour"
#  namespace        = "project-contour"
#  create_namespace = true
#
#  depends_on = [helm_release.metallb]
#
#  set {
#    name  = "contour.image.registry"
#    value = "docker.io"
#    type  = "string"
#  }
#
#  set {
#    name  = "contour.image.repository"
#    value = "projectcontour/contour"
#    type  = "string"
#  }
#
#  set {
#    name  = "contour.image.tag"
#    value = "v1.19.1"
#    type  = "string"
#  }
#
#  set {
#    name  = "envoy.image.registry"
#    value = "docker.io"
#    type  = "string"
#  }
#
#  set {
#    name  = "envoy.image.repository"
#    value = "envoyproxy/envoy"
#    type  = "string"
#  }
#
#  set {
#    name  = "envoy.image.tag"
#    value = "v1.21.0"
#    type  = "string"
#  }
#
#  set {
#    name = "envoy.hostNetwork"
#    value = true
#  }
#
#}

resource "helm_release" "nginx-ingress-controller" {
  name             = "nginx-ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "nginx-ingress-controller"
  create_namespace = true

  depends_on = [helm_release.metallb]

  set {
    name  = "defaultBackend.enabled"
    value = false
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  set {
    name  = "image.registry"
    value = "gcr.io"
    type  = "string"
  }

  set {
    name  = "image.repository"
    value = "k8s-staging-external-dns/external-dns"
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = "v20220128-external-dns-helm-chart-1.7.1-50-g600111f8-arm64v8"
    type  = "string"
  }

#  set {
#    name  = "args[0]"
#    value = "--source=ingress"
#  }
#
#  set {
#    name  = "args[1]"
#    value = "--provider=cloudflare"
#  }
#
#  set {
#    name  = "cloudflare.apiKey"
#    value = var.cloudflare_api_key
#  }
#
#  set {
#    name  = "cloudflare.email"
#    value = var.cloudflare_email
#  }
#
#  set {
#    name = "cloudflare.secretKey"
#    value = "cloudflare-api"
#  }
#
#  set {
#    name  = "cloudflare.proxied"
#    value = false
#  }
}

resource "helm_release" "whoami" {
  name             = "whoami"
  repository       = "https://cowboysysop.github.io/charts/"
  chart            = "whoami"
  namespace        = "whoami"
  create_namespace = true

  depends_on = [
    helm_release.nginx-ingress-controller
  ]

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "whoami.k3s.rwxd.eu"
  }

  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }

  set {
    name = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }
}


resource "helm_release" "adguard" {
  name             = "adguard"
  repository       = "https://k8s-at-home.com/charts/"
  chart            = "adguard-home"
  namespace        = "adguard"
  create_namespace = true

  set {
    name = "env.TZ"
    value = "Europe/Berlin"
  }
}