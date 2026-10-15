terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Assumes `gcloud container clusters get-credentials` has been run (1.4 Part One)
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Your personal sandbox namespace for the semester
resource "kubernetes_namespace" "student" {
  metadata {
    name = var.student_name
    labels = {
      course  = "csai-380"
      student = var.student_name
    }
  }
}

# Docker repository for your course images
resource "google_artifact_registry_repository" "images" {
  location      = var.region
  repository_id = "${var.student_name}-images"
  description   = "CSAI 380 container images for ${var.student_name}"
  format        = "DOCKER"
}

output "namespace" {
  value = kubernetes_namespace.student.metadata[0].name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}
