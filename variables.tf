variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
}

variable "region" {
  description = "The region in which to create resources."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "The name of the storage bucket to create."
  type        = string
}

variable "lifecycle_rules" {
  description = "A map of lifecycle rules with action type, days, and optional storage class."
  type = map(object({
    action_type                         = string
    days                                = number
    storage_class                       = string
    created_before                      = string
    with_state                          = string
    matches_storage_class               = string
    matches_prefix                      = list(string)
    matches_suffix                      = list(string)
    num_newer_versions                  = number
    send_num_newer_versions_if_zero     = bool
    custom_time_before                  = string
    days_since_custom_time              = number
    send_days_since_custom_time_if_zero = bool
    send_age_if_zero                    = bool
    days_since_noncurrent_time          = number
    send_days_since_noncurrent_time_if_zero = bool
    noncurrent_time_before              = string
  }))
  default = {}
}

# Example lifecycle rules{
# # Example lifecycle rules   # Rule 1: Delete objects older than 30 days
# # Example lifecycle rules   rule1 = {
# # Example lifecycle rules     action_type           = "Delete"
# # Example lifecycle rules     days                  = 30
# # Example lifecycle rules     storage_class         = "NEARLINE"
# # Example lifecycle rules     created_before        = "2023-01-01"
# # Example lifecycle rules     with_state            = "ANY"
# # Example lifecycle rules     matches_storage_class = "STANDARD"
# # Example lifecycle rules     matches_prefix        = ["prefix1", "prefix2"]
# # Example lifecycle rules     matches_suffix        = ["suffix1", "suffix2"]
# # Example lifecycle rules     num_newer_versions    = 3
# # Example lifecycle rules     send_num_newer_versions_if_zero = false
# # Example lifecycle rules     custom_time_before    = "2023-01-01"
# # Example lifecycle rules     days_since_custom_time = 10
# # Example lifecycle rules     send_days_since_custom_time_if_zero = false
# # Example lifecycle rules     send_age_if_zero      = false
# # Example lifecycle rules     days_since_noncurrent_time = 20
# # Example lifecycle rules     send_days_since_noncurrent_time_if_zero = false
# # Example lifecycle rules     noncurrent_time_before = "2023-01-01"
# # Example lifecycle rules   }
# # Example lifecycle rules   # Rule 2: Set storage class to NEARLINE for objects older than 60 days
# # Example lifecycle rules   rule2 = {
# # Example lifecycle rules     action_type           = "SetStorageClass"
# # Example lifecycle rules     days                  = 60
# # Example lifecycle rules     storage_class         = "NEARLINE"
# # Example lifecycle rules     created_before        = "2023-01-01"
# # Example lifecycle rules     with_state            = "ANY"
# # Example lifecycle rules     matches_storage_class = "STANDARD"
# # Example lifecycle rules     matches_prefix        = ["prefix3", "prefix4"]
# # Example lifecycle rules     matches_suffix        = ["suffix3", "suffix4"]
# # Example lifecycle rules     num_newer_versions    = 5
# # Example lifecycle rules     send_num_newer_versions_if_zero = true
# # Example lifecycle rules     custom_time_before    = "2023-01-01"
# # Example lifecycle rules     days_since_custom_time = 15
# # Example lifecycle rules     send_days_since_custom_time_if_zero = true
# # Example lifecycle rules     send_age_if_zero      = true
# # Example lifecycle rules     days_since_noncurrent_time = 25
# # Example lifecycle rules     send_days_since_noncurrent_time_if_zero = true
# # Example lifecycle rules     noncurrent_time_before = "2023-01-01"
# # Example lifecycle rules   }
# # Example lifecycle rules }

variable "storage_class" {
  description = "The storage class of the bucket."
  type        = string
  default     = "STANDARD"
}

variable "enable_autoclass" {
  description = "Enable automatic storage class."
  type        = bool
  default     = false
}

variable "retention_duration_seconds" {
  description = "The duration in seconds that objects need to be retained, between 604800(7 days) and 7776000(90 days)"
  type        = number
  default     = 604800
}

variable "enable_versioning" {
  description = "Enable versioning."
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "The public access prevention setting for the bucket."
  type        = string
  default     = "enforced"
}

variable "aide_id" {
  description = "Mandatory label: aide-id"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Mandatory label: environment (e.g. dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "service_tier" {
  description = "Mandatory label: service-tier (e.g. p1, p2, p3)"
  type        = string
  default     = "p3"
}

variable "enable_hierarchical_namespace" {
  description = "Enable hierarchical namespace."
  type        = bool
  default     = false
}

variable "assign_role_iam_binding" {
  description = "Assign the role to the members"
  type        = bool
  default     = false
}

variable "role_member_conditions" {
  type = map(object({
    role       = string
    members    = list(string)
    conditions = list(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}

# Example:{
# # Example:   "role1" = {
# # Example:     role    = "roles/storage.admin"
# # Example:     members = ["user:alice@example.com", "user:bob@example.com"]
# # Example:     conditions = [
# # Example:       {
# # Example:         title       = "Condition1"
# # Example:         description = "Description1"
# # Example:         expression  = "expression1"
# # Example:       }
# # Example:     ]
# # Example:   }
# # Example:   "role2" = {
# # Example:     role    = "roles/storage.viewer"
# # Example:     members = ["user:charlie@example.com"]
# # Example:     conditions = [
# # Example:       {
# # Example:         title       = "Condition2"
# # Example:         description = "Description2"
# # Example:         expression  = "expression2"
# # Example:       }
# # Example:     ]
# # Example:   }
# # Example: }
