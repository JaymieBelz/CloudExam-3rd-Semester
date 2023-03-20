resource "kubernetes_deployment" "azure-vote-back-deploy" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-back"
      }
    }

    template {
      metadata {
        labels = {
          app = "azure-vote-back"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "azure-vote-back"
          image = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"

          env {
            name = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }

          port {
            container_port = 6379
            name = "redis"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "azure-vote-back-svc" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "azure-vote-back"
    }
  }
}

resource "kubernetes_deployment" "azure-vote-front-deploy" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-front"
      }
    }

    strategy {
      rolling_update {
        max_surge = 1
        max_unavailable = 1
      }
    }

    min_ready_seconds = 5

    template {
      metadata {
        labels = {
          app = "azure-vote-front"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "azure-vote-front"
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu = "250m"
            }

            limits = {
              cpu = "500m"
            }
          }

          env {
            name = "REDIS"
            value = "azure-vote-back"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "azure-vote-front-svc" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
#    type = "LoadBalancer"
    port {
      port = 80
    }

    selector = {
      app = "azure-vote-front"
    }
  }
}

