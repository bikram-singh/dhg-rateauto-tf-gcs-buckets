<div align="center">

<img src="docs/gallery/DHG_logo.png" alt="DHG Logo" width="90" height="90"/>

# 🏥 Building a Production-Grade Healthcare Vaccine Pricing Platform on GKE Autopilot

### A Complete Technical Deep-Dive

**Dummy Health Group (DHG) · React 18 · FastAPI · GKE Autopilot · Terraform · Claude AI**

[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115.0-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://python.org)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.4-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![GKE](https://img.shields.io/badge/GKE-Autopilot-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com/kubernetes-engine)
[![Claude AI](https://img.shields.io/badge/AI-Claude_Sonnet-7C3AED?logo=anthropic&logoColor=white)](https://anthropic.com)
[![WIF](https://img.shields.io/badge/Auth-Workload_Identity_Federation-00C853?logo=googlecloud&logoColor=white)](https://cloud.google.com/iam/docs/workload-identity-federation)
[![License](https://img.shields.io/badge/License-Internal-grey)]()

<br/>

> *Seven GitHub repositories. Five Terraform modules. Two application services. Zero stored credentials. One fully automated CI/CD pipeline. This article walks through every layer of a complete, production-deployed healthcare SaaS platform — from VPC design to AI-powered voice advisors.*

<br/>

**🌐 Live:** [`https://dev.gcpcloudhub.shop/vaccinefee-ui`](https://dev.gcpcloudhub.shop/vaccinefee-ui) &nbsp;|&nbsp;
**📖 Swagger:** [`https://dev.gcpcloudhub.shop/vaccinefee/api/docs`](https://dev.gcpcloudhub.shop/vaccinefee/api/docs) &nbsp;|&nbsp;
**❤️ Health:** [`https://dev.gcpcloudhub.shop/vaccinefee/api/health`](https://dev.gcpcloudhub.shop/vaccinefee/api/health)

</div>

---

## 📋 Table of Contents

1. [Project Overview](#1--project-overview)
2. [Repository Map and Responsibilities](#2--repository-map-and-responsibilities)
3. [End-to-End Architecture](#3--end-to-end-architecture)
4. [Infrastructure Provisioning Flow](#4--infrastructure-provisioning-flow)
5. [GCP APIs and Services Enabled](#5--gcp-apis-and-services-enabled)
6. [Service Accounts and IAM Roles](#6--service-accounts-and-iam-roles)
7. [Workload Identity Federation](#7--workload-identity-federation--no-json-keys-anywhere)
8. [VPC and Network Architecture](#8--vpc-and-network-architecture)
9. [GKE Autopilot](#9--gke-autopilot--why-and-how)
10. [Gateway API — Traffic Routing and SSL](#10--gateway-api--traffic-routing-and-ssl)
11. [Cloud SQL + Private Service Connect](#11--cloud-sql--private-service-connect)
12. [FastAPI Backend Architecture](#12--fastapi-backend-architecture)
13. [React Frontend Architecture](#13--react-frontend-architecture)
14. [Frontend-to-Backend Communication](#14--frontend-to-backend-communication-flow)
15. [Request Lifecycle](#15--request-lifecycle--browser-to-database-and-back)
16. [CI/CD Pipeline](#16--cicd-pipeline--deep-dive)
17. [Automated Versioning with bump2version](#17--automated-versioning-with-bump2version)
18. [Security — Defence in Depth](#18--security--defence-in-depth)
19. [Kubernetes Components and Networking](#19--kubernetes-components-and-networking)
20. [Database Schema and Seed Data](#20--database-schema-and-seed-data)
21. [Claude AI Advisor Integration](#21--claude-ai-advisor-integration)
22. [Key Technical Challenges Solved](#22--key-technical-challenges-solved)
23. [What Is Live Today](#23--what-is-live-today)

---

## 1. 🌐 Project Overview

The **DHG Vaccine Fee Pricing Dashboard** is a full-stack enterprise healthcare web application built for the Dummy Health Group. It gives healthcare administrators, procurement teams, and clinicians real-time visibility into vaccine pricing across **108 hospitals** in India, USA, London, Tokyo, Singapore, and more — covering **65 vaccines** and **5,400+ pricing records** seeded from realistic market data.

### 🩺 What the Platform Does

| Capability | Implementation |
|---|---|
| 💉 Live vaccine pricing across 108 hospitals | FastAPI REST API with 5,400+ PostgreSQL records |
| 📊 Hospital comparison, ranking, analytics | 20-page React dashboard with Recharts |
| 🤖 AI-powered vaccine advice with voice | Claude Sonnet + Web Speech API |
| 📅 Appointment booking | 5-step wizard, printable slip |
| 🪪 Digital vaccination records | Printable vaccine card |
| 🔧 Admin CRUD — no Cloud Shell needed | Full admin UI with role gating |
| 🔄 Automated deployments | GitHub Actions + GKE rolling updates |
| 🔖 Zero-downtime versioning | bump2version on every deploy |

### 📊 Platform Statistics

| Metric | Value |
|---|---|
| 📁 **GitHub repositories** | 7 |
| 🏗️ **Terraform modules** | 5 |
| 📄 **React pages** | 20 |
| 📡 **API endpoints** | 25+ |
| 🗄️ **Database tables** | 5 |
| 🏥 **Hospitals** | 108 |
| 💉 **Vaccines** | 65 |
| 💰 **Pricing records** | 5,400+ |
| 🌍 **Countries covered** | 15+ |
| 💻 **Lines of code (approx.)** | 18,000+ |

---

## 2. 🗂️ Repository Map and Responsibilities

The platform is split across seven GitHub repositories — each with a single, clear responsibility:

```
bikram-singh/
├── dhg-rateauto-tf-vpc            🌐 Infrastructure: VPC, subnet, Cloud NAT, firewall
├── dhg-rateauto-tf-gke            ☸️  Infrastructure: GKE Autopilot cluster, Pub/Sub
├── dhg-rateauto-tf-gke-routing    🔀 Infrastructure: Gateway API, HTTPRoutes, SSL cert, static IP
├── dhg-rateauto-tf-postgres       🐘 Infrastructure: Cloud SQL PostgreSQL + PSC endpoint
├── dhg-rateauto-tf-gcs-buckets    🪣 Infrastructure: GCS buckets with lifecycle, labels, IAM
├── dhg-rateauto-api-backend       ⚡ Application: FastAPI Python backend
└── dhg-rateauto-ui-frontend       🏥 Application: React 18 frontend
```

### 🔗 Dependency Graph

```
dhg-rateauto-tf-vpc            (no dependencies — deployed first)
         ↓ outputs: network_name, subnetwork_name, pod/service range names
dhg-rateauto-tf-gke            (depends on VPC outputs)
dhg-rateauto-tf-postgres       (depends on VPC outputs — parallel with GKE)
         ↓
dhg-rateauto-tf-gke-routing    (depends on GKE cluster running + app deployed)
dhg-rateauto-tf-gcs-buckets    (independent — deployed any time)
         ↓
dhg-rateauto-api-backend       (app layer — CI/CD deploys to GKE)
dhg-rateauto-ui-frontend       (app layer — CI/CD deploys to GKE)
```

### ❓ Why Separate Repos?

1. **Independent CI/CD pipelines** — a frontend change triggers a frontend deploy only. Infrastructure changes trigger a Terraform plan/apply only.
2. **Separate Terraform state** — each infra repo has its own GCS state bucket prefix. No state entanglement.
3. **Separate permissions** — the frontend service account only has `container.developer` rights. The VPC service account has `compute.networkAdmin` only. Least privilege per repo.
4. **Clear ownership** — anyone joining the team immediately understands what each repo does.

---

## 3. 🏛️ End-to-End Architecture

![Architecture Diagram](docs/gallery/architecture-diagram.png)

> 📌 *See the draw.io architecture diagram in this repository for a fully detailed GCP services view.*

```
Internet
    │
    │ HTTPS (TLS 1.2+)
    ▼
Global External HTTPS Load Balancer
    Static IP: 8.232.155.177
    Domain: dev.gcpcloudhub.shop
    SSL: Google-managed certificate (auto-renewed)
    │
    ▼
GKE Gateway API (gke-l7-global-external-managed-mc)
    │
    ├─── HTTPRoute: /vaccinefee-ui   ──→ Frontend Service (ClusterIP :8080)
    │                                         ↓
    │                                    React+nginx Pod (2 replicas)
    │
    └─── HTTPRoute: /vaccinefee/api  ──→ Backend Service (ClusterIP :8080)
                                              ↓
                                         FastAPI Pod (1 replica)
                                              │
                                    ┌─────────┼──────────┐
                                    ▼         ▼          ▼
                               asyncpg    httpx       K8s Secrets
                                    │         │
                               Cloud SQL  Anthropic API
                               PSC        (Claude Sonnet)
                               10.10.0.3
```

### 🔑 GCP Project Identity

| Property | Value |
|---|---|
| 🏗️ **Project ID** | `dhg-vaccine-rateauto-nonpord` |
| 🌍 **Region** | `us-central1` |
| 📦 **Artifact Registry** | `us-central1-docker.pkg.dev/dhg-vaccine-rateauto-nonpord/dhg-vaccinefee-repo` |
| 🌐 **Static IP** | `8.232.155.177` |
| 🔗 **Domain** | `dev.gcpcloudhub.shop` |

---

## 4. ⚙️ Infrastructure Provisioning Flow

![CI/CD Pipeline](docs/gallery/routing-ci-cd-pipeline.png)

Every infrastructure repository follows the same CI/CD pattern:

```
PR opened against main
    │
    ├─── terraform fmt -check
    ├─── terraform init (GCS backend)
    ├─── terraform validate
    └─── terraform plan   (posted as PR comment)

Merge to main
    │
    ├─── terraform init
    ├─── terraform plan -out=tfplan
    └─── terraform apply -auto-approve -input=false tfplan
```

### 🗄️ Terraform State Backend

Each repo writes state to a dedicated GCS prefix — no shared state, no locking conflicts:

```
dhg-rateauto-tf-state/
├── vpc/dev/terraform.tfstate
├── gke/dev/terraform.tfstate
├── postgres/dev/terraform.tfstate
├── routing/dev/terraform.tfstate
└── gcs/dev/terraform.tfstate
```

**Why Remote State in GCS?**
- No `.tfstate` files committed to Git
- State locking prevents concurrent runs
- State is versioned — you can inspect what was deployed at any point
- Shared across team members and CI/CD runners without manual sync

---

## 5. 🔌 GCP APIs and Services Enabled

These APIs must be enabled in the GCP project before any Terraform can run:

| API | Used By |
|---|---|
| `compute.googleapis.com` | VPC, subnets, firewalls, static IPs, NAT |
| `container.googleapis.com` | GKE Autopilot cluster |
| `sqladmin.googleapis.com` | Cloud SQL PostgreSQL instance |
| `servicenetworking.googleapis.com` | Private Service Connect endpoint |
| `pubsub.googleapis.com` | GKE cluster event notifications |
| `storage.googleapis.com` | GCS buckets, Terraform state |
| `iam.googleapis.com` | Service accounts, IAM bindings |
| `cloudresourcemanager.googleapis.com` | Project IAM |
| `certificatemanager.googleapis.com` | Google-managed SSL certificates |
| `artifactregistry.googleapis.com` | Docker image registry (GAR) |

```bash
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  sqladmin.googleapis.com \
  servicenetworking.googleapis.com \
  pubsub.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  certificatemanager.googleapis.com \
  artifactregistry.googleapis.com \
  --project=dhg-vaccine-rateauto-nonpord
```

---

## 6. 👥 Service Accounts and IAM Roles

Each repository has its own dedicated service account with the minimum roles needed — the principle of **least privilege** in practice.

| Service Account | Used By | Roles |
|---|---|---|
| `dhg-vpc-tf-sa` | `tf-vpc` CI/CD | `compute.networkAdmin`, `compute.securityAdmin`, `storage.objectAdmin` |
| `dhg-gke-tf-sa` | `tf-gke` CI/CD | `container.clusterAdmin`, `pubsub.admin`, `storage.objectAdmin` |
| `dhg-postgres-tf-sa` | `tf-postgres` CI/CD | `cloudsql.admin`, `compute.networkAdmin`, `storage.objectAdmin` |
| `dhg-routing-tf-sa` | `tf-gke-routing` CI/CD | `compute.networkAdmin`, `compute.loadBalancerAdmin`, `container.developer`, `certificatemanager.editor`, `storage.objectAdmin` |
| `dhg-gcs-tf-sa` | `tf-gcs-buckets` CI/CD | `storage.admin`, `resourcemanager.projectIamAdmin`, `storage.objectAdmin` |
| `dhg-api-deploy-sa` | Backend CI/CD | `artifactregistry.writer`, `container.developer`, `storage.objectAdmin` |
| `dhg-ui-deploy-sa` | Frontend CI/CD | `artifactregistry.writer`, `container.developer`, `storage.objectAdmin` |

### 🔐 IAM Binding for WIF

Each service account is bound to its specific GitHub repository via a WIF attribute condition. A fork or a different repo cannot impersonate it:

```hcl
resource "google_service_account_iam_binding" "wif_binding" {
  service_account_id = google_service_account.deploy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/dhg-rateauto-wif-pool/attribute.repository/bikram-singh/dhg-rateauto-ui-frontend"
  ]
}
```

---

## 7. 🔐 Workload Identity Federation — No JSON Keys Anywhere

This is arguably the most important security decision in the entire platform. Traditional GCP CI/CD stores a service account JSON key in GitHub Secrets — if that leaks, the attacker has permanent access until manual rotation.

WIF eliminates this entirely.

### How WIF Works

```
GitHub Actions runner starts
    │
    ├── GitHub generates a short-lived OIDC token
    │   (signed by GitHub, contains: repo, branch, workflow name)
    │
    ▼
google-github-actions/auth@v2:
    │
    ├── Sends OIDC token to GCP WIF endpoint
    ├── GCP validates token signature, repo claim, and expiry
    │
    ▼
GCP issues temporary credentials (expires in ~1 hour)
    │
    ▼
CI/CD uses credentials: docker push → GAR, kubectl deploy → GKE, terraform apply
    │
Job completes → credentials expire automatically
```

### WIF Configuration

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: ${{ secrets.GCP_WIF_PROVIDER_NONPROD }}
    service_account: ${{ secrets.GCP_WIF_SERVICE_ACCOUNT_NONPROD }}
```

### ⚖️ Security Comparison

| Property | JSON Key | WIF ✅ |
|---|---|---|
| Credential lifetime | Never expires | Expires after ~1 hour |
| Stored in GitHub Secrets | Yes | No |
| Risk if leaked | Permanent access | Useless (already expired) |
| Rotation required | Manual | Automatic per run |
| Google recommendation | ❌ Not recommended | ✅ Recommended |

---

## 8. 🌐 VPC and Network Architecture

![VPC Network Console](docs/gallery/vpc-network-console.png)

The VPC is the foundation everything else sits on — deployed first, before any other infrastructure.

### Network Design

```
VPC: dhg-rateauto-dev-vpc  (routing_mode: REGIONAL)
    │
    └── Subnet: dhg-rateauto-dev-subnet (us-central1)
            Primary CIDR:   10.10.0.0/20   → GKE node IPs    (4,094 addresses)
            Secondary[0]:   10.10.16.0/20  → GKE pod IPs     (4,094 addresses)
            Secondary[1]:   10.10.32.0/24  → GKE service IPs (254 addresses)
```

![VPC Subnet](docs/gallery/vpc-subnet.png)

*The subnet with primary and secondary ranges for GKE pods and services.*

![VPC Primary and Secondary Ranges](docs/gallery/vpc-primary-secondary-ranges.png)

### Why Three IP Ranges?

GKE VPC-native networking requires dedicated secondary ranges for pods and services. Each node receives a `/24` slice from the pod range (256 pod IPs). With a `/20` pod range, that allows 16 nodes before CIDR exhaustion.

### 🛡️ Firewall Rules

```
Priority 65534: deny-all-ingress  (ALL protocols, source: 0.0.0.0/0)
Priority  1000: allow-internal    (TCP+UDP+ICMP, source: VPC CIDRs only)
```

The deny-all at 65534 overrides GCP's implied allow-all at 65535. Result: no external traffic reaches GKE nodes directly — all inbound must arrive through the Gateway load balancer.

### 🌍 Cloud NAT

```hcl
nat_ip_allocate_option             = "AUTO_ONLY"
source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
```

Private nodes need outbound access to pull images from Artifact Registry. Cloud NAT handles this without exposing node IPs. `AUTO_ONLY` means Google automatically provisions and scales NAT IPs.

### 📊 VPC Flow Logs

```hcl
log_config {
  aggregation_interval = "INTERVAL_10_MIN"
  flow_sampling        = 0.5    # 50% sampling — half the cost
  metadata             = "INCLUDE_ALL_METADATA"
}
```

---

## 9. ☸️ GKE Autopilot — Why and How

![GKE Cluster Console](docs/gallery/gke-cluster-console.png)

### Autopilot vs Standard GKE

| Feature | Standard | Autopilot ✅ |
|---|---|---|
| Node management | Manual | Google-managed |
| Scaling | HPA + Cluster Autoscaler | Automatic per-pod |
| Security hardening | Manual | Enforced by default |
| Cost model | Pay per node (even idle) | Pay per pod resource request |
| Pod security standards | Optional | Enforced (Restricted) |
| Shielded nodes | Optional | Always on |
| SSH to nodes | Optional | Not possible |

For a healthcare platform focused on vaccine pricing — not infrastructure operations — Autopilot is the clear choice.

![GKE Dev Cluster Details](docs/gallery/gke-cluster-details.png)

### Cluster Configuration

```hcl
resource "google_container_cluster" "gke" {
  name             = "dhg-rateauto-dev-gke-cluster"
  location         = "us-central1"
  enable_autopilot = true

  private_cluster_config {
    enable_private_nodes    = true   # Nodes: no public IPs
    enable_private_endpoint = false  # Control plane: publicly reachable
  }

  release_channel {
    channel = "STABLE"
  }

  cost_management_config {
    enabled = true  # Per-namespace billing breakdown
  }
}
```

### 📡 Pub/Sub Notifications

```hcl
resource "google_pubsub_topic" "gke_notifications" {
  name = "dhg-rateauto-dev-gke-cluster-notifications"
}
```

Receives real-time events: upgrade available, security bulletins, node pool changes — subscribe any Cloud Function or Slack webhook.

### 🕐 Maintenance Windows

Weekday windows 7–11 AM UTC (12:30–4:30 PM IST) give GKE a regular 4-hour slot for upgrades during low-traffic hours.

---

## 10. 🔀 Gateway API — Traffic Routing and SSL

![GKE Gateway Console](docs/gallery/routing-gateway-console.png)

### Why Gateway API Over Kubernetes Ingress

| Feature | Ingress | Gateway API ✅ |
|---|---|---|
| HTTP → HTTPS redirect | Annotation hacks | Native |
| Header-based routing | Limited | Full |
| Traffic splitting | Not supported | Native canary/A-B |
| Role separation | Single resource | Gateway + HTTPRoute |
| Load balancer type | HTTP(S) LB v1 | Global HTTP(S) LB v2 |
| Certificate management | Manual | Google-managed |
| Status | Being deprecated | Active development |

### Resources Created

| Resource | Type | Description |
|---|---|---|
| `google_compute_global_address` | GCP | Static external IP `8.232.155.177` |
| `Gateway` manifest | Kubernetes | GKE Gateway with HTTPS listener |
| `HTTPRoute` (UI) | Kubernetes | `/vaccinefee-ui` → Frontend Service |
| `HTTPRoute` (API) | Kubernetes | `/vaccinefee/api` → Backend Service |
| `HTTPRoute` (redirect) | Kubernetes | HTTP 80 → 301 HTTPS |
| `google_compute_managed_ssl_certificate` | GCP | Auto-renewed TLS cert |

![HTTPRoutes](docs/gallery/routing-httproutes.png)

*HTTPRoutes routing `/vaccinefee-ui` and `/vaccinefee/api` to their respective backend services.*

![SSL Policy](docs/gallery/routing-ssl-policy.png)

![Gateway Resource View](docs/gallery/gateway-resource-view.png)

### HTTPRoute Examples

```yaml
# Frontend route
rules:
  - matches:
      - path:
          type: PathPrefix
          value: /vaccinefee-ui
    backendRefs:
      - name: dhg-vaccinefee-ui
        port: 8080

# HTTP to HTTPS redirect
rules:
  - filters:
      - type: RequestRedirect
        requestRedirect:
          scheme: https
          statusCode: 301
```

### 🔒 SSL Certificate

```hcl
resource "google_compute_managed_ssl_certificate" "dhg_ssl" {
  managed {
    domains = ["dev.gcpcloudhub.shop"]
  }
}
```

Google-managed certificates are fully automatic: provisioned without a CSR, renewed 30 days before expiry, and completely free. Activation takes 5–15 minutes after DNS validation.

---

## 11. 🐘 Cloud SQL + Private Service Connect

![Cloud SQL Instances](docs/gallery/postgres-cloudsql-instances.png)

### PSC Architecture

```
GKE Pod (FastAPI)
    │
    │ Connects to 10.10.0.3:5432 (private IP — never public)
    ▼
PSC Forwarding Rule (dhg-vaccinefee-psc-fwd)
    │ load_balancing_scheme = ""  (PSC-specific requirement)
    ▼
PSC Tunnel (one-way, no VPC peering, no route propagation)
    ▼
Cloud SQL Instance (Google-managed network)
    │
    ▼
PostgreSQL 14 (zero internet exposure)
```

![PSC Endpoint](docs/gallery/postgres-psc-endpoint.png)

*The PSC forwarding rule connecting the static private IP to the Cloud SQL service attachment.*

### Why PSC Over Public IP

| Method | Security | Complexity |
|---|---|---|
| Public IP + SSL | Exposed to internet scans | Simple |
| VPC Peering | Private, but IP conflicts possible | Moderate |
| PSC ✅ | Fully private, no peering, no route leakage | Moderate |

### Instance Details

![Postgres Dev Details](docs/gallery/postgres-dev-details.png)

```hcl
settings {
  tier              = "db-custom-2-4096"   # 2 vCPU, 4 GB RAM
  edition           = "ENTERPRISE"
  disk_type         = "PD_SSD"
  disk_size         = 20
  disk_autoresize   = true
  availability_type = "ZONAL"
}

backup_configuration {
  enabled          = true
  start_time       = "00:00"     # Midnight UTC = 5:30 AM IST
  location         = "us"        # Multi-region storage
  retained_backups = 7
}
```

### 🔐 Database Credentials Flow

```
GitHub Secret: DB_PASSWORD
    ↓ injected at CI/CD runtime as TF_VAR_db_password
Terraform variable (sensitive = true)
    ↓ creates Cloud SQL user
K8s Secret: dhg-vaccinefee-db-secret (encrypted in etcd)
    ↓ injected as environment variable
FastAPI: os.getenv("DB_PASSWORD")
```

The password is never in code, tfvars, Docker images, or CI/CD logs.

---

## 12. ⚡ FastAPI Backend Architecture

### Application Structure

```
dhg-vaccinefee-api/app/
├── main.py          FastAPI app, CORS, lifespan, router registration
├── database.py      Async SQLAlchemy engine + session factory
├── models/          SQLAlchemy ORM models (5 tables)
└── routers/
    ├── auth.py          JWT login, /me, user CRUD
    ├── hospitals.py     Hospital CRUD (5 endpoints)
    ├── vaccines.py      Vaccine CRUD (5 endpoints)
    ├── departments.py   Department CRUD (5 endpoints)
    ├── pricing.py       Pricing CRUD + paginated list (5 endpoints)
    └── ai_advisor.py    Claude Sonnet proxy (1 endpoint)
```

![Swagger UI](docs/gallery/backend-swagger-ui.png)

*Full Swagger UI with OAS 3.1 schema — all 25+ endpoints documented.*

### 🔄 Async Architecture

The entire stack is async end-to-end:

```python
# database.py
DATABASE_URL = f"postgresql+asyncpg://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
engine = create_async_engine(DATABASE_URL, echo=False)

async def get_db():
    async with AsyncSession(engine) as session:
        yield session

# Example router — fully async
@router.get("/pricing/")
async def list_pricing(limit: int = 500, skip: int = 0, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Pricing).offset(skip).limit(limit))
    return result.scalars().all()
```

A single uvicorn worker serves hundreds of concurrent requests — no thread pool, no blocking.

### 🔐 Auth Endpoints

![Auth Endpoints](docs/gallery/backend-api-auth.png)

```python
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM  = "HS256"
EXPIRY     = 480  # 8 hours

def create_access_token(data: dict) -> str:
    payload = {**data, "exp": datetime.utcnow() + timedelta(minutes=EXPIRY)}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
```

### 💰 Pricing Endpoints

![Pricing Endpoints](docs/gallery/backend-api-pricing.png)

### RBAC

```python
def require_admin(current_user: User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return current_user

@router.post("/hospitals/")
async def create_hospital(data: HospitalCreate, _: User = Depends(require_admin)):
    ...
```

### ❤️ Health Check

![API Health](docs/gallery/backend-api-health.png)

```json
{"status": "healthy", "service": "dhg-vaccinefee-api", "version": "2.0.0"}
```

### bcrypt Directly — Not passlib

```python
import bcrypt
# passlib breaks with bcrypt >= 4.0.0 — use bcrypt directly, pinned to 4.0.1
hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
valid  = bcrypt.checkpw(plain.encode("utf-8"), stored_hash)
```

---

## 13. 🏥 React Frontend Architecture

### UI Gallery

![Login](docs/gallery/login.png)

*Login page — JWT authentication with role-based access.*

![Dashboard Light Mode](docs/gallery/dashboard-light.png)

*Dashboard in light mode — Live KPIs, filter bar, price chart.*

![Dashboard Dark Mode](docs/gallery/dashboard-dark.png)

*Dashboard in dark mode — Deep Ocean Teal theme.*

### Stack

| Technology | Version | Role |
|---|---|---|
| ⚛️ React | 18 | Component framework |
| 📜 JavaScript | ES2022 | Primary language (92.6%) |
| 📊 Recharts | Latest | Bar, line, pie, radar charts |
| 🎨 Lucide React | 0.383.0 | 200+ icons |
| 🌐 Web Speech API | Browser native | Voice input + TTS |
| 🌐 nginx | 1.25-alpine | Production serving |

### 🎨 Theme System

Every one of the 20 pages imports a central theme helper — toggling `darkMode` instantly re-renders the entire application:

```javascript
export const theme = (dark = true) => ({
  page:    dark ? "#0A1628"                : "#EBF5F7",
  card:    dark ? "#0D1F35"                : "#FFFFFF",
  text:    dark ? "rgba(255,255,255,0.88)" : "#0C2340",
  textSec: dark ? "rgba(255,255,255,0.55)" : "#2E6B7A",
  teal:    "#2DD4BF",  // Same in both modes
  // ...
});

const t = theme(darkMode);
<div style={{ background: t.card, color: t.text }}>
```

### 📱 20 Pages Overview

![Hospitals List](docs/gallery/hospitals-list.png)

*Hospitals List — 108 hospitals across India, USA, Europe, Asia.*

![Hospital Profile](docs/gallery/hospital-profile.png)

*Hospital Profile — bar chart, pie chart, vaccine pricing table.*

![Pricing](docs/gallery/pricing.png)

*Pricing table — 5,400+ records with filters, status badges, insurance badges.*

![Price History](docs/gallery/price-history.png)

*Price History — 10-month historical trend, compare up to 5 vaccines.*

![Vaccine Search](docs/gallery/vaccine-search.png)

*Vaccine Search — filter by age group, category, max price slider.*

![City Analytics](docs/gallery/city-analytics.png)

*City Analytics — Delhi vs Mumbai vs Bengaluru comparison.*

![Appointments](docs/gallery/appointments.png)

*Appointments — 5-step booking wizard with printable slip.*

![Vaccination Card](docs/gallery/vaccination-card.png)

*Vaccination Card — digital record, printable.*

| Group | Pages | Key Features |
|---|---|---|
| 🏠 Main | Dashboard | Live KPIs, 30s auto-refresh, filters, chart, export |
| 🏥 Hospitals | Departments, List, Profiles, Rankings, Compare | Bar chart, pie chart, radar chart |
| 💉 Vaccines | Search, Details, Card, Appointments | Filter sliders, printable card, 5-step wizard |
| 💰 Pricing | Pricing, History, Prediction | 5,400+ records, trends, linear regression |
| 📊 Analytics | City Analytics, Advanced Reports, Reports | Delhi vs Mumbai, PDF export |
| 🔧 Admin | Admin Panel, User Management, Audit Log | Full CRUD, role assignment, action tracking |
| 🤖 AI | Vaccine Advisor | Claude Sonnet, voice input, TTS |

### 🔍 Global Search

The header search bar queries four entity types simultaneously using `useMemo`:

```javascript
const searchResults = useMemo(() => {
  if (searchQuery.length < 2) return null;
  const q = searchQuery.toLowerCase();
  return {
    pages:       ALL_PAGES.filter(p => p.label.toLowerCase().includes(q)),
    vaccines:    vaccines.filter(v => v.name.toLowerCase().includes(q)),
    hospitals:   hospitals.filter(h => h.name.toLowerCase().includes(q)),
    departments: departments.filter(d => d.name.toLowerCase().includes(q)),
  };
}, [searchQuery, vaccines, hospitals, departments]);
```

### Paginated Pricing Fetch — Solving 504 Timeout

```javascript
const fetchAllPricing = async (token) => {
  let all = [], skip = 0;
  while (true) {
    const batch = await fetchJSONAuth(`/pricing/?limit=500&skip=${skip}`, token);
    if (!batch.length) break;
    all = [...all, ...batch];
    if (batch.length < 500) break;
    skip += 500;
  }
  return all;  // Full 5,400+ records
};
```

Fetching all 5,400+ records at once causes a 504 Gateway Timeout. Batching in groups of 500 solves this completely.

### 🐳 Docker Multi-Stage Build

```dockerfile
FROM node:20-alpine AS builder       # Stage 1: Build
WORKDIR /app
RUN npm ci && npm run build

FROM nginx:1.25-alpine               # Stage 2: Serve
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 8080
```

Final image: ~50MB — no Node.js, no npm, no source code.

---

## 14. 🔄 Frontend-to-Backend Communication Flow

```
React component calls /vaccinefee/api/pricing/?limit=500
    │
    ▼  Authorization: Bearer eyJ...
User's browser → HTTPS → Gateway → Backend HTTPRoute
    │
    ▼
FastAPI pod
    ├── Validates JWT signature and expiry
    ├── Executes async DB query via asyncpg
    └── Returns JSON response
    │
    ▼
Browser → React state update → UI re-renders
```

### Why API Calls Go Back Through the Gateway

The React app at `https://dev.gcpcloudhub.shop/vaccinefee-ui` makes API calls to `https://dev.gcpcloudhub.shop/vaccinefee/api` — the **same domain**. This means:
- **CORS is not an issue** — same origin
- **SSL is always enforced** — no mixed content
- **All traffic is logged** at the Gateway level
- **No direct pod-to-pod communication** — frontend never talks to backend via internal DNS

---

## 15. 🔁 Request Lifecycle — Browser to Database and Back

```
Step 1:  User opens https://dev.gcpcloudhub.shop/vaccinefee-ui
         DNS resolves → 8.232.155.177

Step 2:  TLS handshake with Google's Global Load Balancer
         TLS 1.2+ enforced — older versions rejected

Step 3:  Gateway evaluates path prefix
         /vaccinefee-ui → UI HTTPRoute → Frontend Service

Step 4:  Frontend Service → React+nginx pod
         nginx serves index.html — React SPA bootstraps

Step 5:  React validates JWT from localStorage
         if expired → redirect to LoginPage

Step 6:  React fetches pricing data
         GET /vaccinefee/api/pricing/?limit=500
         Authorization: Bearer eyJ...

Step 7:  Same Gateway, different route
         /vaccinefee/api → API HTTPRoute → Backend Service

Step 8:  FastAPI validates JWT, builds SQLAlchemy query

Step 9:  asyncpg connects to 10.10.0.3:5432 (PSC)
         Traffic stays on Google's private network — never internet
         PostgreSQL returns rows

Step 10: Response travels back
         FastAPI → Gateway → Browser → React re-renders

Total latency: ~50–200ms typical (India region)
```

---

## 16. 🔄 CI/CD Pipeline — Deep Dive

### Frontend Pipeline

![Frontend CI/CD Pipeline](docs/gallery/frontend-ci-cd-pipeline.png)

```
push to main
    ↓
setup (guardrail — detect bot commits)
    ↓
ci: npm install → ESLint → npm test → npm build
    ↓
build-and-push-image:
    WIF auth → docker buildx build → push to GAR
    bump2version patch → git push --follow-tags
    ↓
deploy-dev:
    kubectl set image → kubectl rollout status
```

### Backend Pipeline

![Backend CI/CD Pipeline](docs/gallery/backend-ci-cd-pipeline.png)

```
push to main
    ↓
setup (guardrail)
    ↓
ci: pip install → flake8 → pytest
    ↓
build-and-push-image:
    WIF auth → docker buildx build → push to GAR
    bump2version patch → git push --follow-tags
    ↓
deploy-dev:
    kubectl set image → kubectl rollout status
```

### 🛡️ Infinite Loop Prevention

```bash
if git log -1 --pretty=%s | grep -q '\[.*\]'; then
  echo "Auto commit detected - aborting."
  ABORT="true"
fi
```

The bump2version commit `[2026-05-30] GitHub Actions Build 0.0.1 → 0.0.2` matches `\[.*\]`. When detected, all subsequent jobs are skipped — no infinite deploy loop.

### Zero-Downtime Rolling Update

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # One extra pod during update
    maxUnavailable: 0  # Never reduce below desired count
progressDeadlineSeconds: 900
```

New pods come up and pass health checks before old pods are terminated.

### GKE Workload Views

![Frontend GKE Workload](docs/gallery/frontend-gke-workload.png)

*Frontend workload — 2 replicas running in `dhg-rateauto-dev-namespace`.*

![Backend GKE Workload](docs/gallery/backend-gke-workload.png)

*Backend workload — 1 replica with secrets injected as environment variables.*

---

## 17. 🔖 Automated Versioning with bump2version

Every successful deployment automatically increments the patch version. No manual version management.

### Configuration

```ini
# .bumpversion.cfg (frontend)
[bumpversion]
current_version = 0.0.3
commit = True
tag = True
tag_name = v{new_version}
message = [{now:%Y-%m-%d}] GitHub Actions Build {current_version} → {new_version}

[bumpversion:file:dhg-vaccinefee-ui/package.json]
search = "version": "{current_version}"
replace = "version": "{new_version}"

[bumpversion:file:VERSION]
search = {current_version}
replace = {new_version}
```

```ini
# .bumpversion.cfg (backend — no package.json)
[bumpversion]
current_version = 0.0.1

[bumpversion:file:VERSION]
search = {current_version}
replace = {new_version}
```

### What Happens on Every Deploy

```
1. bump2version patch runs
2. Updates package.json → "version": "0.0.2"
3. Updates VERSION → 0.0.2
4. Creates commit: "[2026-05-30] GitHub Actions Build 0.0.1 → 0.0.2"
5. Creates tag: v0.0.2
6. git push origin main --follow-tags
```

GitHub shows a clean, dated history:
```
● [2026-05-30] GitHub Actions Build 0.0.1 → 0.0.2    github-actions[bot]
● fix: resolve pricing filter not resetting              bikram-singh
```

---

## 18. 🔒 Security — Defence in Depth

The platform implements security at 7 distinct layers. A breach of one still leaves 6 intact.

| Layer | What | Implementation |
|---|---|---|
| 🔐 **1 — CI/CD** | Zero stored credentials | Workload Identity Federation — OIDC tokens per run |
| 🌐 **2 — Network** | Private everything | Private GKE nodes, no public DB IP, PSC tunnel |
| 🔑 **3 — Application** | JWT + RBAC | HS256, 8-hour expiry, Admin/Viewer roles |
| 🔒 **4 — Passwords** | bcrypt hashing | Cost factor 12 — brute-force resistant |
| 🗝️ **5 — Infrastructure** | K8s Secrets | Encrypted in etcd, injected as env vars |
| 🛡️ **6 — Transport** | HTTPS enforced | TLS 1.2+, 301 redirect, auto-renewed cert |
| 🐳 **7 — Containers** | Minimal images | nginx:1.25-alpine (~50MB), python:3.12-slim |

### Security Stack Summary

```
Layer 1 — CI/CD:          WIF (no JSON keys)
Layer 2 — Network:        PSC (private DB), HTTPS (Gateway), VPC isolation
Layer 3 — Application:    JWT (8hr tokens), bcrypt (passwords)
Layer 4 — Authorization:  RBAC (Admin/Viewer roles)
Layer 5 — Infrastructure: K8s Secrets (encrypted at rest in etcd)
Layer 6 — Container:      Minimal base images, read-only tmp volume
```

---

## 19. ☸️ Kubernetes Components and Networking

### Per-Application K8s Resources

```
Deployment        Pod template + rolling update strategy + resource limits
Service           ClusterIP — routes Gateway traffic to pods
HPA               Auto-scales replicas on CPU/memory
ServiceAccount    Identity for Workload Identity binding
```

### Resource Requests and Limits

```yaml
# Frontend
resources:
  requests:
    memory: "128Mi"
    cpu:    "100m"
  limits:
    memory: "256Mi"
    cpu:    "500m"
```

GKE Autopilot schedules pods based on requested resources and bills accordingly. Accurate requests = accurate billing.

### K8s Secrets

```yaml
# dhg-vaccinefee-db-secret
DB_HOST:     10.10.0.3
DB_PORT:     5432
DB_NAME:     dhg-vaccinefee-db
DB_USER:     dhg-vaccinefee-user
DB_PASSWORD: <encrypted in etcd>

# dhg-vaccinefee-jwt-secret
JWT_SECRET_KEY: <encrypted>

# dhg-vaccinefee-anthropic-api-secret
ANTHROPIC_API_KEY: <encrypted>
```

### Namespace Isolation

All resources live in `dhg-rateauto-dev-namespace`:
- Resource quota management per namespace
- RBAC scoping
- Cost management breakdown (enabled at cluster level)

---

## 20. 🗄️ Database Schema and Seed Data

### Five Tables

```sql
-- Hospitals (108 rows)
CREATE TABLE hospitals (
  id SERIAL PRIMARY KEY, name VARCHAR(200), location VARCHAR(200), address VARCHAR(500)
);

-- Vaccines (65 rows — real manufacturers)
CREATE TABLE vaccines (
  id SERIAL PRIMARY KEY, name VARCHAR(200), manufacturer VARCHAR(200), description TEXT
);

-- Departments (13 rows)
CREATE TABLE departments (id SERIAL PRIMARY KEY, name VARCHAR(100), description TEXT);

-- Pricing (5,400+ rows — core junction table)
CREATE TABLE pricing (
  id SERIAL PRIMARY KEY,
  vaccine_id    INTEGER REFERENCES vaccines(id),
  hospital_id   INTEGER REFERENCES hospitals(id),
  department_id INTEGER REFERENCES departments(id),
  price             NUMERIC(10,2),
  status            VARCHAR(50),    -- Available / Low Stock / Out of Stock
  insurance_covered VARCHAR(10),    -- Yes / No / Vco
  stock_quantity    INTEGER
);

-- Users (2 rows)
CREATE TABLE users (
  id SERIAL PRIMARY KEY, username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(200) NOT NULL,  -- bcrypt hash
  full_name VARCHAR(100), role VARCHAR(20) DEFAULT 'Viewer',
  is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT NOW()
);
```

### 🌱 Seed Data Strategy

**Hospitals (108 total):**
- India: AIIMS Delhi, Apollo, Fortis, Max, Medanta, 18 Haryana district cities
- USA: Mayo Clinic, Johns Hopkins, Cleveland Clinic, MGH, Cedars-Sinai — 45 total
- International: Royal London, Tokyo Medical, Singapore General, Dubai Health

**Vaccines (65 total with real manufacturers):**
- Pfizer (Comirnaty, Prevnar), GSK (Shingrix, Cervarix), Serum Institute (Covishield, Covavax), Bharat Biotech (Covaxin, Rotavac), Sanofi, AstraZeneca, Moderna

**Pricing logic:**
- Government hospitals: subsidised or free
- Private Indian hospitals: ₹500–₹5,000 market rates
- International hospitals: 20–30% premium
- ~70% Available, ~20% Low Stock, ~10% Out of Stock

---

## 21. 🤖 Claude AI Advisor Integration

![Vaccine Advisor](docs/gallery/vaccine-advisor.png)

*The AI Vaccine Advisor — Claude Sonnet with voice input and text-to-speech.*

### Backend Architecture

```python
# routers/ai_advisor.py
@router.post("/ai/chat")
async def chat(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    vaccines = (await db.execute(select(Vaccine))).scalars().all()
    hospitals = (await db.execute(select(Hospital))).scalars().all()

    system_prompt = f"""
    You are DHG's expert vaccine advisor.
    Available vaccines: {', '.join([v.name for v in vaccines])}
    Available hospitals: {', '.join([h.name for h in hospitals])}
    Prices range from ₹250 to ₹12,000.
    """

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={"x-api-key": os.getenv("ANTHROPIC_API_KEY"), "anthropic-version": "2023-06-01"},
            json={"model": "claude-sonnet-4-20250514", "max_tokens": 1000,
                  "system": system_prompt, "messages": request.messages}
        )
    return {"content": response.json()["content"][0]["text"]}
```

### 🎤 Voice Interface

```javascript
// Voice input — Web Speech API (free, no external service)
const recognition = new window.SpeechRecognition();
recognition.lang = "en-IN";  // Indian English
recognition.onresult = (e) => setInput(e.results[0][0].transcript);

// Text to speech
const utt = new SpeechSynthesisUtterance(cleanText);
utt.lang = "en-IN";  utt.rate = 0.9;
window.speechSynthesis.speak(utt);
```

The `en-IN` locale is tuned for Indian English accents and vaccine terminology. No external service — completely free using the browser's built-in Web Speech API.

### Conversation Context

Full history is sent with every message — Claude remembers the conversation:

```javascript
const updatedHistory = [...conversationHistory, { role: "user", content: userMessage }];
const response = await callAI(updatedHistory);
setConversationHistory([...updatedHistory, { role: "assistant", content: response }]);
```

---

## 22. 🔧 Key Technical Challenges Solved

| Challenge | Root Cause | Solution |
|---|---|---|
| 504 Gateway Timeout | 5,400+ records in one request | Paginated fetch — 500 records per batch |
| passlib incompatible with bcrypt | `passlib` breaks with `bcrypt >= 4.0.0` | Used `bcrypt` directly, pinned to `4.0.1` |
| `$0` appearing on every page | Literal `$0` in Dashboard.jsx line 187 | Manual code review, removed stray character |
| Light mode invisible text | Hardcoded colors assumed dark mode | Central `theme.js` — `t.text`, `t.card` everywhere |
| React `&&` renders `0` | `{price && \`₹${price}\`}` renders "0" when price=0 | Changed to `{price > 0 ? \`₹${price}\` : ""}` |
| ESLint warnings failing CI | `CI=true` promotes warnings to errors | Fixed 60+ ESLint warnings systematically |
| WIF auth failure | Wrong secret names in workflow | Matched `GCP_WIF_PROVIDER_NONPROD` exactly |
| bump2version infinite loop | Bot commit triggers new pipeline | Guardrail: detect `[.*]` pattern, set `ABORT=true` |
| Sidebar duplicate icon | Two nav items used same Lucide icon | Used `Building2` alias for Hospital Profiles |

---

## 23. ✅ What Is Live Today

| Component | URL | Status |
|---|---|---|
| 🌐 **Frontend Dashboard** | [`https://dev.gcpcloudhub.shop/vaccinefee-ui`](https://dev.gcpcloudhub.shop/vaccinefee-ui) | ✅ Live |
| ❤️ **API Health** | [`https://dev.gcpcloudhub.shop/vaccinefee/api/health`](https://dev.gcpcloudhub.shop/vaccinefee/api/health) | ✅ Live |
| 📖 **Swagger UI** | [`https://dev.gcpcloudhub.shop/vaccinefee/api/docs`](https://dev.gcpcloudhub.shop/vaccinefee/api/docs) | ✅ Live |
| 🐘 **PostgreSQL** | PSC `10.10.0.3:5432` | ✅ Connected |
| 🔄 **CI/CD Frontend** | GitHub Actions | ✅ Automated |
| 🔄 **CI/CD Backend** | GitHub Actions | ✅ Automated |
| ☸️ **GKE Dev Cluster** | `dhg-rateauto-dev-gke-cluster` | ✅ Running |
| 🔖 **bump2version** | Both repos | ✅ Active |

### 🔑 Login Credentials

| Role | Username | Password | Access |
|---|---|---|---|
| 👑 **Admin** | `bikram` | `Admin@123` | Full CRUD |
| 👁️ **Viewer** | `viewer` | `View@123` | Read-only |

---

## 🏁 Conclusion

This platform represents a complete, production-grade cloud-native healthcare application — built entirely with open standards and Google-recommended practices:

- 🏗️ **Infrastructure as Code** — every GCP resource Terraform-managed, version-controlled, repeatable
- 🔐 **Zero stored credentials** — Workload Identity Federation eliminates the key management problem
- 🛡️ **Private by default** — PSC database, private GKE nodes, firewall deny-all baseline
- ⚡ **Async everywhere** — FastAPI + asyncpg handles thousands of concurrent requests without blocking
- ✅ **Automated quality gates** — ESLint and flake8 prevent broken code from reaching production
- 🔖 **Automated versioning** — every deploy is tagged, traceable, and dated
- 🤖 **AI-native** — Claude Sonnet integrated as a first-class feature with voice support

The separation into seven repositories with independent CI/CD pipelines means any component can be updated, scaled, or replaced without touching the others. Clear boundaries, clear ownership, clear audit trail.

---

<div align="center">

**Maintained by Bikram Singh · DHG Platform Engineering**

`dhg-vaccine-rateauto-nonpord` · `us-central1` · React 18 + FastAPI + GKE Autopilot

</div>
