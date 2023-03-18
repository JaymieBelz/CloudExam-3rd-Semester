resource "kubernetes_ingress_v1" "voting-app-ingress" {
  metadata {
    name      = "azure-vote-front"
    labels = {
      name = "azure-vote-front"
    }
    annotations = {
       "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {
    rule {
      host = "voting-app.jaymiebelz.me"
      http {
        path {
          backend {
            service {
              name = "azure-vote-front"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

  #  tls {
   #   hosts = ["voting-app.jaymie.me"]
    #  secret_name = "voting-app-tls"
    #}    
  }
}

resource "kubernetes_ingress_v1" "sock-shop-ingress" {
  metadata {
    name      = "sock-shop"
    namespace = "sock-shop"
    labels = {
      name = "front-end"
    }
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {
    rule {
      host = "sock-shop.jaymiebelz.me"
      http {
        path {
          backend {
            service {
              name = "front-end"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    #tls {
     # hosts = ["sock-shop.jaymie.me"]
      #secret_name = "sock-shop-tls"
    #}
  }
}