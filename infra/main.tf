terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 4.42"
  }
}

provider "google" {
  project = "850496727105"
}

# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  # disable_on_destroy = true
}

# Deployment locations
locals {
  # locations = ["europe-west4", "europe-west1", "europe-central2"]
  locations = ["europe-west4"]
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  name = "next-ecommerce"

  # Create a deployment for each location
  for_each = toset(local.locations)
  location = each.key

  template {
    spec {
      containers {
        image = "europe-docker.pkg.dev/alif-iac/eu.gcr.io/next-ecommerce:${var.app_version}"
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1000m"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1",
        "autoscaling.knative.dev/maxScale" = "3"
      }
    }

  }
  autogenerate_revision_name = true


  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  for_each = toset(local.locations)

  service     = google_cloud_run_service.run_service[each.key].name
  location    = google_cloud_run_service.run_service[each.key].location
  policy_data = data.google_iam_policy.noauth.policy_data
}

# resource "google_compute_global_address" "ip" {
#   name = "service-ip"
# }

# resource "google_compute_region_network_endpoint_group" "neg" {
#   for_each = toset(local.locations)

#   name                  = "neg-${each.key}"
#   network_endpoint_type = "SERVERLESS"
#   region                = each.key

#   cloud_run {
#     service = google_cloud_run_service.run_service[each.key].name
#   }
# }

# resource "google_compute_backend_service" "backend" {
#   name     = "backend"
#   protocol = "HTTP"
#   #enable_cdn = true

#   dynamic "backend" {
#     for_each = toset(local.locations)

#     content {
#       group = google_compute_region_network_endpoint_group.neg[backend.key].id
#     }
#   }
# }

# resource "google_compute_url_map" "url_map" {
#   name            = "url-map"
#   default_service = google_compute_backend_service.backend.id
# }

# resource "google_compute_target_http_proxy" "http_proxy" {
#   name    = "http-proxy"
#   url_map = google_compute_url_map.url_map.id
# }

# resource "google_compute_global_forwarding_rule" "frontend" {
#   name       = "frontend"
#   target     = google_compute_target_http_proxy.http_proxy.id
#   port_range = "80"
#   ip_address = google_compute_global_address.ip.address
# }

# Display the service URL
output "service_url" {
  value = toset([
    for service in google_cloud_run_service.run_service : service.status[0].url
  ])
}

# output "static_ip" {
#   value = google_compute_global_address.ip.address
# }
