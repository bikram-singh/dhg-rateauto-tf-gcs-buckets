resource "google_storage_bucket" "default" {
  name     = var.bucket_name
  location = var.region
  project  = var.project_id

  storage_class = var.storage_class

  uniform_bucket_level_access = true

  public_access_prevention = var.public_access_prevention

  autoclass {
    enabled = var.enable_autoclass
  }

  hierarchical_namespace {
    enabled = var.enable_hierarchical_namespace
  }

  versioning {
    enabled = var.enable_versioning
  }

  soft_delete_policy {
    retention_duration_seconds = var.retention_duration_seconds
  }

  # Mandatory labels to satisfy org policy custom.enforceLabelsCloudStorageBuckets
  labels = {
    aide-id      = var.aide_id
    environment  = var.environment
    service-tier = var.service_tier
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lifecycle_rule.value.action_type == "SetStorageClass" ? lifecycle_rule.value.storage_class : null
      }
      condition {
        age                        = lifecycle_rule.value.days
        send_age_if_zero           = lifecycle_rule.value.send_age_if_zero ? lifecycle_rule.value.send_age_if_zero : false
        created_before             = lifecycle_rule.value.created_before != "" ? lifecycle_rule.value.created_before : null
        with_state                 = lifecycle_rule.value.with_state != "" ? lifecycle_rule.value.with_state : null
        matches_storage_class      = lifecycle_rule.value.matches_storage_class != "" ? lifecycle_rule.value.matches_storage_class : null
        matches_prefix             = lifecycle_rule.value.matches_prefix != [] ? lifecycle_rule.value.matches_prefix : null
        matches_suffix             = lifecycle_rule.value.matches_suffix != [] ? lifecycle_rule.value.matches_suffix : null
        num_newer_versions         = lifecycle_rule.value.num_newer_versions != "" ? lifecycle_rule.value.num_newer_versions : null
        send_num_newer_versions_if_zero = lifecycle_rule.value.send_num_newer_versions_if_zero ? lifecycle_rule.value.send_num_newer_versions_if_zero : false
        custom_time_before         = lifecycle_rule.value.custom_time_before != "" ? lifecycle_rule.value.custom_time_before : null
        days_since_custom_time     = lifecycle_rule.value.days_since_custom_time != 0 ? lifecycle_rule.value.days_since_custom_time : null
        send_days_since_custom_time_if_zero = lifecycle_rule.value.send_days_since_custom_time_if_zero ? lifecycle_rule.value.send_days_since_custom_time_if_zero : false
        days_since_noncurrent_time = lifecycle_rule.value.days_since_noncurrent_time != 0 ? lifecycle_rule.value.days_since_noncurrent_time : null
        send_days_since_noncurrent_time_if_zero = lifecycle_rule.value.send_days_since_noncurrent_time_if_zero ? lifecycle_rule.value.send_days_since_noncurrent_time_if_zero : false
        noncurrent_time_before     = lifecycle_rule.value.noncurrent_time_before != "" ? lifecycle_rule.value.noncurrent_time_before : null
      }
    }
  }
}

resource "google_storage_bucket_iam_binding" "default" {
  for_each = var.assign_role_iam_binding ? var.role_member_conditions : {}
  bucket   = google_storage_bucket.default.name
  role     = each.value.role
  members  = each.value.members

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
