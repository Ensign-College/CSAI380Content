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
