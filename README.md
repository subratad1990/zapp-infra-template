# zapp-infra-template

GitHub template repository for **regular infrastructure deployments** using the
[zapp-devsecops-framework](https://github.com/Zappsec/zapp-devsecops-framework).

## Use This Template

Click the **"Use this template"** button above to create a new repo from this template.

---

## What You Get

A pre-wired infrastructure project with:

- **3-stage pipeline** (Security CI → Quality CI → Deploy dev/staging/prod)
- **Branch protection** (no direct push to main, branch naming enforced)
- **IaC scanning** via Checkov (CIS Benchmark - Terraform + Helm)
- **Secrets scanning** via Gitleaks
- **Dependency scanning** via OWASP + Dependabot
- **SBOM generation** (CycloneDX)
- **Environment approval gates** (dev auto, staging 1 approval, prod 2 approvals)
- **Terraform + Helm** deployment structure

---

## Repository Structure

```
zapp-infra-template/
├── .github/
│   └── workflows/
│       └── pipeline.yml          # Calls zapp-devsecops-framework
├── terraform/
│   ├── modules/                  # Your Terraform modules
│   │   ├── aks/
│   │   ├── networking/
│   │   ├── storage/
│   │   └── key-vault/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
└── helm/
    ├── charts/
    │   └── app/                  # Your Helm chart
    └── values/
        ├── dev.yaml
        ├── staging.yaml
        └── prod.yaml
```

---

## Getting Started

### 1. Configure GitHub Environments

Go to **Settings → Environments** and create:
- `dev` - no protection rules
- `staging` - 1 required reviewer
- `prod` - 2 required reviewers

### 2. Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure service principal client ID (OIDC) |
| `AZURE_TENANT_ID` | Azure tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

### 3. Update pipeline.yml

Edit `.github/workflows/pipeline.yml` and update:
- `HELM_RELEASE` - your application name
- `HELM_NAMESPACE` - your Kubernetes namespace
- Terraform directory paths

### 4. Add your Terraform modules and Helm charts

Place your Terraform code in `terraform/environments/<env>/` and your
Helm chart in `helm/charts/app/`.

---

## Pipeline Flow

```
PR/Push to feature/*
    |
    v
[ci-security.yml] - branch policy + gitleaks + checkov
    |
    v (only if security passed)
[ci-quality.yml] - OWASP + SBOM + license + CIS report
    |
    v (only on merge to main)
[cd-deployment.yml/dev]     - auto deploy
[cd-deployment.yml/staging] - 1 approval
[cd-deployment.yml/prod]    - 2 approvals
```

---

## Framework Source

All security logic lives in: [Zappsec/zapp-devsecops-framework](https://github.com/Zappsec/zapp-devsecops-framework)

This template is a thin wrapper — update `@main` in pipeline.yml to pin to a
specific framework version (e.g., `@v1.0.0`) for stability.

---

## Deployment Mode

This template uses `deployment-mode: infra`. This activates:
- Gitleaks (standard secrets)
- Checkov (Terraform + Helm + Dockerfile)
- OWASP dependency check
- SBOM generation
- No CodeQL SAST, no AI supply chain scans

To enable CodeQL SAST, change `deployment-mode` to `all` in `pipeline.yml`.
