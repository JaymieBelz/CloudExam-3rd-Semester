# Create kubernetes deployment for cart

resource "kubernetes_deployment" "kube-carts-deployment" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "carts"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "carts"
      }
    }
    template {
      metadata {
        labels = {
          name = "carts"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/carts:0.4.8"
          name  = "carts"

      env {
        name = "JAVA_OPTS"
        value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "500Mi"
        }
        requests = {
          cpu = "100m"
          memory = "200Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
        #privileged = false
        #readOnlyRootFilesystem = true
       # runAsNonRoot = true
        #runAsUser = 10001
      }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }
        }

     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }

      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "kube-carts-service" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "carts"
    }
  }
  spec {
    selector = {
      name = "carts"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "kube-carts-db-deployment" {
  metadata {
    name      = "carts-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "carts-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "carts-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "carts-db"
        }
      }
      spec {
        container {
          image = "mongo"
          name  = "carts-db"

       port {
        name = "mongo"
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }

        #readOnlyRootFilesystem = false
        read_only_root_filesystem = true

        }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }

        }
     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }

      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }

      }
    }
  }
}


# service for cart-db

resource "kubernetes_service" "kube-carts-db-service" {
  metadata {
    name      = "carts-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "carts-db"
    }
  }
  spec {
    selector = {
      name = "carts-db"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "kube-catalogue-deployment" {
  metadata {
    name      = "catalogue"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "catalogue"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "catalogue"
      }
    }
    template {
      metadata {
        labels = {
          name = "catalogue"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/catalogue:0.3.5"
          name  = "catalogue"
          command = ["/app"]
          args = [ "-port=80" ]
          resources {
            limits = {
              cpu = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu = "100m"
              memory = "100Mi"
            }
          }

          port {
            container_port = 80
          }

            security_context {
                capabilities {
                drop = ["ALL"]
                add = ["NET_BIND_SERVICE"]
                }

                read_only_root_filesystem = true
                run_as_non_root = true
                run_as_user = 10001
                #readOnlyRootFilesystem = true
                #runAsNonRoot = true
                #runAsUser = 10001
            }

            liveness_probe {
                http_get {
                    path = "/health"
                    port = 80
                }
                initial_delay_seconds = 300
                period_seconds = 3
            }

            readiness_probe {
                http_get {
                    path = "/health"
                    port = 80
                }
                initial_delay_seconds = 180
                period_seconds = 3
            }
        }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
    }
  }
}
}




# Create kubernetes  for cart service

resource "kubernetes_service" "kube-catalogue-service" {
  metadata {
    name      = "catalogue"
    namespace = kubernetes_namespace.kube-namespace.id
   /*  annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "catalogue"
    }
  }
  spec {
    selector = {
      name = "catalogue"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "kube-catalogue-db-deployment" {
  metadata {
    name      = "catalogue-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "catalogue-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "catalogue-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "catalogue-db"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/catalogue-db:0.3.0"
          name  = "catalogue-db"

        port {
        name = "mysql"
        container_port = 3306
      }
      env {
        name = "MYSQL_ROOT_PASSWORD"
        value = "fake_password"
      }

      env {
        name = "MYSQL_DATABASE"
        value = "socksdb"
      }
        }

       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
    }
  }
}
}


# service for cart-db

resource "kubernetes_service" "kube-catalogue-db-service" {
  metadata {
    name      = "catalogue-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "catalogue-db"
    }
  }
  spec {
    selector = {
      name = "catalogue-db"
    }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "kube-front-end-deployment" {
  metadata {
    name      = "front-end"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "front-end"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "front-end"
      }
    }
    template {
      metadata {
        labels = {
          name = "front-end"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/front-end:0.3.12"
          name  = "front-end"

        env {
        name = "SESSION_REDIS"
        value = "true"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "1000Mi"
        }
        requests = {
          cpu = "100m"
          memory = "300Mi"
        }
      }

      port {
        container_port = 8079
      }

      security_context {
        capabilities {
          drop = ["ALL"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
        #readOnlyRootFilesystem = true
        #runAsNonRoot = true
        #runAsUser = 10001
      }

      liveness_probe {
        http_get {
          path = "/"
          port = 8079
        }
        initial_delay_seconds = 300
        period_seconds = 3
      }

      readiness_probe {
        http_get {
          path = "/"
          port = 8079
        }
        initial_delay_seconds = 30
        period_seconds = 3
      }
        }

       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
    }
  }
}

}


# Create kubernetes  for cart service

resource "kubernetes_service" "kube-front-end-service" {
  metadata {
    name      = "front-end"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "front-end"
    }
  }
  spec {
    type = "NodePort"
    selector = {
      name = "front-end"
    }
    port {
      port        = 80
      target_port = 8079
      node_port   = 30002
    }
  }
}

# Create kubernetes deployment for orders

resource "kubernetes_deployment" "orders-deployment" {
  metadata {
    name      = "orders"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "orders"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "orders"
      }
    }
    template {
      metadata {
        labels = {
          name = "orders"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/orders:0.4.7"
          name  = "orders"

      env {
        name = "JAVA_OPTS"
        value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
      }

      resources {
        limits = {
          cpu = "500m"
          memory = "500Mi"
        }
        requests = {
          cpu = "100m"
          memory = "300Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        #readOnlyRootFilesystem = true
        run_as_non_root = true
       # runAsNonRoot = true
       run_as_user = 10001
        #runAsUser = 10001
      }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }
        }

     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }
      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "orders-service" {
  metadata {
    name      = "orders"
    namespace = kubernetes_namespace.kube-namespace.id

    labels = {
        name = "orders"
    }
  }
  spec {
    selector = {
      name = "orders"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "orders-db-deployment" {
  metadata {
    name      = "orders-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "orders-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "orders-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "orders-db"
        }
      }
      spec {
        container {
          image = "mongo"
          name  = "orders-db"

       port {
        name = "mongo"
        container_port = 27017
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }
       # readOnlyRootFilesystem = false
        read_only_root_filesystem = false

        }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }

        }
     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}


# service for cart-db

resource "kubernetes_service" "orders-db-service" {
  metadata {
    name      = "orders-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "orders-db"
    }
  }
  spec {
    selector = {
      name = "orders-db"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "payment-deployment" {
  metadata {
    name      = "payment"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "payment"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "payment"
      }
    }
    template {
      metadata {
        labels = {
          name = "payment"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/payment:0.4.3"
          name  = "payment"

      resources {
        limits = {
          cpu = "200m"
          memory = "200Mi"
        }
        requests = {
          cpu = "99m"
          memory = "100Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
       # readOnlyRootFilesystem = true
       # runAsNonRoot = true
       # runAsUser = 10001
      }


      liveness_probe {
        http_get {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 300
        period_seconds = 3
      }

      readiness_probe {
        http_get {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 180
        period_seconds = 3
      }


      }
      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
    }
  }
}
}




# Create kubernetes  for cart service

resource "kubernetes_service" "payment-service" {
  metadata {
    name      = "payment"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "payment"
    }
  }
  spec {
    selector = {
      name = "payment"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "queue-master-deployment" {
  metadata {
    name      = "queue-master"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "queue-master"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "queue-master"
      }
    }
    template {
      metadata {
        labels = {
          name = "queue-master"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/queue-master:0.3.1"
          name  = "queue-master"

      env {
        name = "JAVA_OPTS"
        value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "500Mi"
        }
        requests = {
          cpu = "100m"
          memory = "300Mi"
        }
      }

      port {
        container_port = 80
      }

      }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "queue-master-service" {
  metadata {
    name      = "queue-master"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "queue-master"
    }
  }
  spec {
    selector = {
      name = "queue-master"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "rabbitmq-deployment" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "rabbitmq"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "rabbitmq"
      }
    }
    template {
      metadata {
        labels = {
          name = "rabbitmq"
        }
       /*  annotations = {
          "prometheus.io/scrape" = "false"
        } */
      }
      spec {
        container {
          image = "rabbitmq:3.6.8-management"
          name  = "rabbitmq"

      port {
        name = "rabbitmq"
        container_port = 5672
      }

      port {
        name = "management"
        container_port = 15672
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }
        #readOnlyRootFilesystem = false
        read_only_root_filesystem = false
      }

        }

        container {
            image = "kbudde/rabbitmq-exporter"
            name  = "rabbitmq-exporter"

            port {
            container_port = 9090
            name = "exporter"
             }
        }

      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "rabbitmq-service" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.kube-namespace.id
/*     annotations = {
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
    } */
    labels = {
        name = "rabbitmq"
    }
  }
  spec {
    selector = {
      name = "rabbitmq"
    }
    port {
      name = "rabbitmq"
      port        = 5672
      target_port = 5672
    }
    port {
        protocol = "TCP"
        name = "exporter"
        port        = 9090
        target_port = "exporter"
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "session-db-deployment" {
  metadata {
    name      = "session-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "session-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "session-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "session-db"
        }
       /*  annotations = {
          prometheus.io.scrape = "false"
        } */
      }
      spec {
        container {
          image = "redis:alpine"
          name  = "session-db"

      port {
        name = "redis"
        container_port = 6379
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }
        #readOnlyRootFilesystem = false
        read_only_root_filesystem = false
      }

      }
        node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
    }
  }
}
}



# Create kubernetes  for cart service

resource "kubernetes_service" "session-db-service" {
  metadata {
    name      = "cartsession-dbs"
    namespace = kubernetes_namespace.kube-namespace.id

    labels = {
        name = "session-db"
    }
  }
  spec {
    selector = {
      name = "session-db"
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "shipping-deployment" {
  metadata {
    name      = "shipping"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "shipping"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "shipping"
      }
    }
    template {
      metadata {
        labels = {
          name = "shipping"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/shipping:0.4.8"
          name  = "shipping"

      env {
        name = "JAVA_OPTS"
        value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
      }

      env {
        name = "ZIPKIN"
        value = "zipkin.jaeger.svc.cluster.local"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "500Mi"
        }
        requests = {
          cpu = "100m"
          memory = "300Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
        /* readOnlyRootFilesystem = true
        runAsNonRoot = true
        runAsUser = 10001 */
      }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }
        }

     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "shipping-service" {
  metadata {
    name      = "shipping"
    namespace = kubernetes_namespace.kube-namespace.id
    #annotations = {
    #    prometheus.io/scrape: "true"
    #    prometheus.io/port: "8080"
    #    prometheus.io/path: "/actuator/prometheus"
    #}

    labels = {
        name = "shipping"
    }
  }
  spec {
    selector = {
      name = "shipping"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Create kubernetes deployment for cart

resource "kubernetes_deployment" "user-deployment" {
  metadata {
    name      = "user"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "user"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "user"
      }
    }
    template {
      metadata {
        labels = {
          name = "user"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/user:0.4.7"
          name  = "user"

      env {
        name = "mongo"
        value = "user-db:27017"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "200Mi"
        }
        requests = {
          cpu = "100m"
          memory = "100Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
        /* readOnlyRootFilesystem = true
        runAsNonRoot = true
        runAsUser = 10001 */
      }

     liveness_probe {
         http_get {
              path = "/health"
              port = 80
        }
        initial_delay_seconds = 300
        period_seconds = 3
    }

     readiness_probe {
        http_get {
            path = "/health"
            port = 80
         }
            initial_delay_seconds = 180
            period_seconds = 3
    }
        }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "user-service" {
  metadata {
    name      = "user"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "user"
    }
  }
  spec {
    selector = {
      name = "user"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "user-db-deployment" {
  metadata {
    name      = "user-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "user-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "user-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "user-db"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/user-db:0.3.0"
          name  = "user-db"

       port {
        name = "mongo"
        container_port = 27017
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }
        read_only_root_filesystem = true
       # readOnlyRootFilesystem = false

        }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }

        }

     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }
      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}


# service for cart-db

resource "kubernetes_service" "user-db-service" {
  metadata {
    name      = "user-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "user-db"
    }
  }
  spec {
    selector = {
      name = "user-db"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

