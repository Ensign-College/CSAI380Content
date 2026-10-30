variable "project_id" {
  description = "Vocareum-provided GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for course resources"
  type        = string
  default     = "us-east1"
}

variable "student_name" {
  description = "Your GitHub username, lowercase (used for namespace and registry names)"
  type        = string
}
