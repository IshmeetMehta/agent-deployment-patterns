# Future Enhancements & Next Steps

This document outlines the roadmap for extending the GKE Production-Grade Agent Deployment Kit with advanced deployment strategies and operations.

## Roadmap

### 1. Canary Releases (Priority: High)
*   **Goal:** Implement a **Canary Release** strategy for the production rollout to minimize blast radius on new versions.
*   **Implementation:**
    *   Configure Cloud Deploy `Canary` strategy with specific percentage thresholds (e.g., 10%, 25%, 50%, 100%).
    *   Utilize **Google Service Mesh** (Istio) or **Gateway API** for fine-grained traffic shifting during the rollout.
    *   Add automated "Canary Analysis" using **Cloud Monitoring** to trigger auto-rollback if error rates increase during traffic shifting.
*   **Reference:** [Cloud Deploy Canary Deployment Strategy](https://cloud.google.com/deploy/docs/deployment-strategies/canary)

### 2. Infrastructure as Code (Terraform)
*   **Goal:** Provide a comprehensive set of Terraform modules to replace the `deploy.sh` script for enterprise environments.
*   **Implementation:**
    *   Module for GKE Autopilot clusters with Workload Identity pre-configured.
    *   Module for Cloud Deploy pipelines, targets, and automation rules.
    *   Module for Eventarc triggers and Artifact Registry repositories.

### 3. Automated Observability & Monitoring
*   **Goal:** Integrate out-of-the-box monitoring dashboards and alerting rules for the deployed agents.
*   **Implementation:**
    *   Add **Cloud Logging** log-based metrics for agent latency and error rates.
    *   Configure **Service Level Objectives (SLOs)** in Cloud Monitoring.
    *   Automate the creation of **Uptime Checks** via Terraform/gcloud.

### 4. Security & Governance (Policy Controller)
*   **Goal:** Enforce best practices at the cluster level using GKE Policy Controller.
*   **Implementation:**
    *   Enforce resource limits (CPU/Memory).
    *   Restrict root execution and privileged containers.
    *   Audit manifests for security vulnerabilities before they reach the cluster.

---

## Contributing
We welcome improvements to the [templates/](./templates/) or additional deployment patterns. Please refer to the [instructions.md](./instructions.md) for the "Production-Grade" standards before submitting a pull request.
