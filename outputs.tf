output "bucket_name" {
  description = "The name of the created bucket."
  value       = google_storage_bucket.default.name
}
