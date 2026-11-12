# Raw-data bucket for the Week 3 ETL pipeline (3.4)
resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_id}-${var.student_name}-raw-data"
  location = var.region

  uniform_bucket_level_access = true
  # Not public — the pipeline authenticates; see 6.1 stewardship discussion
  public_access_prevention = "enforced"

  force_destroy = true # course sandbox only
}

output "raw_data_bucket" {
  value = google_storage_bucket.raw_data.name
}

# Lets Airflow's pods in your namespace read the CSV (extract) and write task logs to this bucket,
# through GKE Workload Identity: no keys, and no access for anything outside your namespace.
data "google_project" "current" {}

resource "google_storage_bucket_iam_member" "airflow_read_write" {
  bucket = google_storage_bucket.raw_data.name
  role   = "roles/storage.objectUser"
  member = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/namespace/${var.student_name}"
}
