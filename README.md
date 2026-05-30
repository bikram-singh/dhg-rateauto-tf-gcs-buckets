# dhg-rateauto-tf-gcs-buckets

> **Terraform module to provision enterprise-grade Google Cloud Storage (GCS) buckets for the DHG Rate Automation platform — with autoclass, versioning, lifecycle rules, hierarchical namespace, soft delete, mandatory org-policy labels, and conditional IAM bindings.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Resources Created](#resources-created)
- [Features](#features)
- [Variables Reference](#variables-reference)
- [Outputs](#outputs)
- [Environments](#environments)
- [Usage](#usage)
- [Lifecycle Rules](#lifecycle-rules)
- [IAM Bindings](#iam-bindings)
- [Mandatory Labels](#mandatory-labels)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security](#security)
- [Provider Versions](#provider-versions)

---

## Overview

This repository contains Terraform configuration to provision and manage **Google Cloud Storage (GCS) buckets** for the DHG Rate Automation platform (`dhg-vaccine-rateauto-nonpord`).

The module is designed to be **reusable across environments** (dev, stage, prod) via environment-specific `.tfvars` files located in the `environments/` directory. It enforces organisation policy compliance through mandatory labels and applies enterprise security defaults such as `public_access_prevention = enforced` and `uniform_bucket_level_access = true`.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   GitHub Actions CI/CD Pipeline                  │
│              (Workload Identity Federation — No Keys)            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Terraform (>= 1.4)                            │
│               google provider  < 6.11.0                         │
└────────┬─────────────────────────────────────────────┬──────────┘
         │                                             │
         ▼                                             ▼
┌─────────────────────┐                  ┌─────────────────────────┐
│  google_storage_    │                  │  google_storage_bucket_ │
│  bucket.default     │                  │  iam_binding.default     │
│                     │                  │                          │
│  • Autoclass        │                  │  • Role assignment       │
│  • Versioning       │                  │  • Member list           │
│  • Soft delete      │                  │  • CEL conditions        │
│  • Hierarchical NS  │                  │  • for_each map          │
│  • Lifecycle rules  │                  └─────────────────────────┘
│  • Mandatory labels │
│  • Public access    │
│    prevention       │
└─────────────────────┘
```

---

## Repository Structure

```
dhg-rateauto-tf-gcs-buckets/
│
├── .github/
│   └── workflows/
│       └── terraform.yml          # CI/CD pipeline (plan + apply)
│
├── environments/
│   ├── dev.tfvars                 # Dev environment variables
│   ├── stage.tfvars               # Stage environment variables
│   └── prod.tfvars                # Prod environment variables
│
├── main.tf                        # Core GCS bucket + IAM resources
├── variables.tf                   # All input variable definitions
├── outputs.tf                     # Output values
├── providers.tf                   # Google provider configuration
├── versions.tf                    # Terraform + provider version constraints
└── README.md                      # This file
```

---

## Prerequisites

Before using this module, ensure you have:

| Requirement | Version / Details |
|---|---|
| Terraform | `>= 1.4` |
| Google Provider | `< 6.11.0` |
| GCP Project | `dhg-vaccine-rateauto-nonpord` |
| GCP APIs enabled | `storage.googleapis.com`, `iam.googleapis.com` |
| IAM permissions | `storage.admin`, `resourcemanager.projectIamAdmin` |
| Authentication | Workload Identity Federation (CI/CD) or `gcloud auth application-default login` (local) |

---

## Resources Created

| Resource | Type | Description |
|---|---|---|
| `google_storage_bucket.default` | GCS Bucket | Primary storage bucket with all enterprise features |
| `google_storage_bucket_iam_binding.default` | IAM Binding | Conditional role bindings on the bucket |

---

## Features

### ✅ Uniform Bucket Level Access
```hcl
uniform_bucket_level_access = true
```
Disables per-object ACLs — all access controlled via IAM only. Required for enterprise compliance.

### ✅ Public Access Prevention
```hcl
public_access_prevention = "enforced"  # default
```
Prevents any public access to bucket contents — even if someone tries to set a public ACL.

### ✅ Autoclass
```hcl
autoclass {
  enabled = var.enable_autoclass  # default: false
}
```
Automatically transitions objects to the most cost-effective storage class based on access patterns (STANDARD → NEARLINE → COLDLINE → ARCHIVE).

### ✅ Hierarchical Namespace
```hcl
hierarchical_namespace {
  enabled = var.enable_hierarchical_namespace  # default: false
}
```
Enables folder-like semantics (similar to a filesystem). Required for analytics workloads using BigQuery, Dataproc, or Dataflow.

### ✅ Versioning
```hcl
versioning {
  enabled = var.enable_versioning  # default: false
}
```
Keeps previous versions of objects. Protects against accidental deletion and overwrites.

### ✅ Soft Delete Policy
```hcl
soft_delete_policy {
  retention_duration_seconds = var.retention_duration_seconds  # default: 604800 (7 days)
}
```
Deleted objects are retained for the specified duration (7–90 days) and can be recovered. Default is 7 days (604800 seconds), maximum is 90 days (7776000 seconds).

### ✅ Dynamic Lifecycle Rules
Fully configurable lifecycle rules supporting all GCS conditions:
- `Delete` or `SetStorageClass` actions
- Age-based transitions
- Storage class matching
- Prefix/suffix filtering
- Version-based conditions
- Custom time conditions
- Noncurrent version conditions

### ✅ Conditional IAM Bindings
```hcl
dynamic "condition" {
  for_each = each.value.conditions
  content {
    title      = condition.value.title
    description = condition.value.description
    expression  = condition.value.expression  # CEL expression
  }
}
```
Supports attribute-based access control (ABAC) using CEL (Common Expression Language) conditions.

### ✅ Mandatory Organisation Policy Labels
```hcl
labels = {
  aide-id      = var.aide_id
  environment  = var.environment
  service-tier = var.service_tier
}
```
Satisfies the GCP org policy `custom.enforceLabelsCloudStorageBuckets` — all 3 labels are mandatory.

---

## Variables Reference

### Core Variables

| Variable | Type | Default | Required | Description |
|---|---|---|---|---|
| `project_id` | `string` | — | ✅ Yes | GCP project ID |
| `region` | `string` | `us-central1` | No | GCP region for the bucket |
| `bucket_name` | `string` | — | ✅ Yes | Unique name for the GCS bucket |
| `storage_class` | `string` | `STANDARD` | No | Default storage class (`STANDARD`, `NEARLINE`, `COLDLINE`, `ARCHIVE`) |

### Feature Flags

| Variable | Type | Default | Description |
|---|---|---|---|
| `enable_autoclass` | `bool` | `false` | Enable automatic storage class transitions |
| `enable_versioning` | `bool` | `false` | Enable object versioning |
| `enable_hierarchical_namespace` | `bool` | `false` | Enable hierarchical namespace (filesystem semantics) |
| `public_access_prevention` | `string` | `enforced` | Public access prevention (`enforced` or `inherited`) |
| `retention_duration_seconds` | `number` | `604800` | Soft delete retention period in seconds (604800–7776000) |

### Mandatory Labels (Org Policy)

| Variable | Type | Default | Description |
|---|---|---|---|
| `aide_id` | `string` | `""` | Mandatory org label: Application/Service ID |
| `environment` | `string` | `dev` | Mandatory org label: environment (`dev`, `stage`, `prod`) |
| `service_tier` | `string` | `p3` | Mandatory org label: priority tier (`p1`, `p2`, `p3`) |

### IAM Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `assign_role_iam_binding` | `bool` | `false` | Whether to create IAM bindings |
| `role_member_conditions` | `map(object)` | `{}` | Map of role → members + CEL conditions |

### Lifecycle Rules

| Variable | Type | Default | Description |
|---|---|---|---|
| `lifecycle_rules` | `map(object)` | `{}` | Map of lifecycle rules with full condition support |

#### Lifecycle Rule Object Schema

```hcl
lifecycle_rules = {
  "rule_name" = {
    action_type                          = string       # "Delete" or "SetStorageClass"
    days                                 = number       # Age in days
    storage_class                        = string       # Target class for SetStorageClass
    created_before                       = string       # Date "YYYY-MM-DD"
    with_state                           = string       # "LIVE", "ARCHIVED", "ANY"
    matches_storage_class                = string       # e.g. "STANDARD"
    matches_prefix                       = list(string) # Object prefix filter
    matches_suffix                       = list(string) # Object suffix filter
    num_newer_versions                   = number       # Number of newer versions
    send_num_newer_versions_if_zero      = bool
    custom_time_before                   = string       # Date "YYYY-MM-DD"
    days_since_custom_time               = number
    send_days_since_custom_time_if_zero  = bool
    send_age_if_zero                     = bool
    days_since_noncurrent_time           = number
    send_days_since_noncurrent_time_if_zero = bool
    noncurrent_time_before               = string       # Date "YYYY-MM-DD"
  }
}
```

---

## Outputs

| Output | Description |
|---|---|
| `bucket_name` | The name of the created GCS bucket |

---

## Environments

Environment-specific configurations are in the `environments/` directory:

```
environments/
├── dev.tfvars      # Development environment
├── stage.tfvars    # Staging environment
└── prod.tfvars     # Production environment
```

### Example `dev.tfvars`

```hcl
project_id   = "dhg-vaccine-rateauto-nonpord"
region       = "us-central1"
bucket_name  = "dhg-rateauto-dev-bucket"
environment  = "dev"
aide_id      = "dhg-rateauto"
service_tier = "p3"

enable_versioning             = true
enable_autoclass              = false
enable_hierarchical_namespace = false
retention_duration_seconds    = 604800   # 7 days

storage_class            = "STANDARD"
public_access_prevention = "enforced"
```

---

## Usage

### Local Development

```bash
# 1. Clone the repository
git clone https://github.com/bikram-singh/dhg-rateauto-tf-gcs-buckets.git
cd dhg-rateauto-tf-gcs-buckets

# 2. Authenticate with GCP
gcloud auth application-default login

# 3. Initialise Terraform
terraform init

# 4. Plan for a specific environment
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# 5. Apply
terraform apply -auto-approve -input=false tfplan
```

### Destroy

```bash
terraform destroy -var-file=environments/dev.tfvars
```

---

## Lifecycle Rules

### Example 1 — Delete objects older than 30 days

```hcl
lifecycle_rules = {
  "delete-old-objects" = {
    action_type                          = "Delete"
    days                                 = 30
    storage_class                        = ""
    created_before                       = ""
    with_state                           = "ANY"
    matches_storage_class                = ""
    matches_prefix                       = []
    matches_suffix                       = []
    num_newer_versions                   = 0
    send_num_newer_versions_if_zero      = false
    custom_time_before                   = ""
    days_since_custom_time               = 0
    send_days_since_custom_time_if_zero  = false
    send_age_if_zero                     = false
    days_since_noncurrent_time           = 0
    send_days_since_noncurrent_time_if_zero = false
    noncurrent_time_before               = ""
  }
}
```

### Example 2 — Move to NEARLINE after 60 days

```hcl
lifecycle_rules = {
  "move-to-nearline" = {
    action_type                          = "SetStorageClass"
    days                                 = 60
    storage_class                        = "NEARLINE"
    created_before                       = ""
    with_state                           = "LIVE"
    matches_storage_class                = "STANDARD"
    matches_prefix                       = []
    matches_suffix                       = []
    num_newer_versions                   = 0
    send_num_newer_versions_if_zero      = false
    custom_time_before                   = ""
    days_since_custom_time               = 0
    send_days_since_custom_time_if_zero  = false
    send_age_if_zero                     = false
    days_since_noncurrent_time           = 0
    send_days_since_noncurrent_time_if_zero = false
    noncurrent_time_before               = ""
  }
}
```

### Example 3 — Delete noncurrent versions after 7 days

```hcl
lifecycle_rules = {
  "delete-noncurrent" = {
    action_type                             = "Delete"
    days                                    = 0
    storage_class                           = ""
    created_before                          = ""
    with_state                              = "ARCHIVED"
    matches_storage_class                   = ""
    matches_prefix                          = []
    matches_suffix                          = []
    num_newer_versions                      = 1
    send_num_newer_versions_if_zero         = false
    custom_time_before                      = ""
    days_since_custom_time                  = 0
    send_days_since_custom_time_if_zero     = false
    send_age_if_zero                        = false
    days_since_noncurrent_time              = 7
    send_days_since_noncurrent_time_if_zero = false
    noncurrent_time_before                  = ""
  }
}
```

---

## IAM Bindings

### Enable IAM Binding

```hcl
assign_role_iam_binding = true

role_member_conditions = {
  "storage-admin-binding" = {
    role    = "roles/storage.admin"
    members = [
      "serviceAccount:dhg-vaccinefee-sa@dhg-vaccine-rateauto-nonpord.iam.gserviceaccount.com",
      "user:bikram@dummyhealthgroup.com"
    ]
    conditions = []
  }

  "storage-viewer-binding" = {
    role    = "roles/storage.objectViewer"
    members = ["group:dhg-developers@dummyhealthgroup.com"]
    conditions = [
      {
        title       = "DevAccessOnly"
        description = "Access restricted to dev environment resources"
        expression  = "resource.name.startsWith('projects/_/buckets/dhg-rateauto-dev')"
      }
    ]
  }
}
```

---

## Mandatory Labels

This module enforces three mandatory labels required by the GCP organisation policy `custom.enforceLabelsCloudStorageBuckets`:

| Label | Variable | Example Values | Purpose |
|---|---|---|---|
| `aide-id` | `aide_id` | `dhg-rateauto` | Application/Service identifier |
| `environment` | `environment` | `dev`, `stage`, `prod` | Deployment environment |
| `service-tier` | `service_tier` | `p1`, `p2`, `p3` | Service priority tier |

**Buckets without these labels will be rejected by the org policy.**

---

## CI/CD Pipeline

The `.github/workflows/terraform.yml` pipeline uses **Workload Identity Federation (WIF)** — no service account JSON keys are stored anywhere.

```
On Pull Request:
  → terraform fmt -check
  → terraform init
  → terraform validate
  → terraform plan -var-file=environments/<env>.tfvars

On Push to main:
  → terraform init
  → terraform plan -var-file=environments/<env>.tfvars -out=tfplan
  → terraform apply -auto-approve -input=false tfplan
```

### WIF Authentication Flow

```
GitHub Actions Runner
      ↓
GitHub OIDC Token (short-lived)
      ↓
Google WIF Pool validates token
      ↓
Short-lived GCP credentials granted
      ↓
Terraform applies changes
      ↓
Credentials expire after job completes
```

---

## Security

| Feature | Configuration | Detail |
|---|---|---|
| **Public Access** | `enforced` | No public access ever — org policy compliant |
| **Uniform ACL** | `true` | IAM-only access, no per-object ACLs |
| **Soft Delete** | 7–90 days | Recovery window for accidental deletions |
| **Versioning** | Optional | Previous object versions retained |
| **Conditional IAM** | CEL expressions | Attribute-based access control |
| **No JSON Keys** | WIF only | CI/CD uses short-lived OIDC tokens |
| **Org Policy Labels** | Mandatory | Ensures compliance and cost attribution |

---

## Provider Versions

```hcl
# versions.tf
terraform {
  required_version = ">= 1.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 6.11.0"
    }
  }
}

# providers.tf
provider "google" {
  project = var.project_id
  region  = var.region
}
```

> **Note:** Google provider is pinned to `< 6.11.0` to ensure compatibility with the current Terraform configuration. Test before upgrading.

---

## Related Repositories

| Repository | Purpose |
|---|---|
| `dhg-rateauto-tf-vpc` | VPC, subnets, firewall rules |
| `dhg-rateauto-tf-gke` | GKE Autopilot clusters (dev/test/stage) |
| `dhg-rateauto-tf-gke-routing` | GKE Gateway API, HTTPRoutes, SSL |
| `dhg-rateauto-tf-gcs-buckets` | **This repo** — GCS bucket provisioning |
| `dhg-rateauto-api-backend` | FastAPI backend (Python) |
| `dhg-rateauto-ui-frontend` | React frontend dashboard |

---

## Maintainer

**Bikram Singh**
- GCP Project: `dhg-vaccine-rateauto-nonpord`
- Region: `us-central1`
