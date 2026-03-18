# Future Enhancements & Next Steps (Open Discussion)

This document tracks the progress of advanced deployment patterns and features for the GKE Production-Grade Agent Deployment Kit.

## Roadmap Tracking

### 1. Multi-Platform Deployment (Cloud Run)
*   **Objective:** Adapt the current pipeline to deploy agents to **Cloud Run**.
*   **Progress:**
    - [x] Approved Idea
    - [x] Developed (Templates/Docs) - See [templates/cloudrun/](./templates/cloudrun/)
    - [ ] Verified/Tested (User Only)

### 2. Multi-Platform Deployment (Agent Engine)
*   **Objective:** Adapt the pipeline for **Agent Engine** deployments.
*   **Progress:**
    - [x] Approved Idea
    - [x] Developed (Templates/Docs) - See [templates/agentengine/](./templates/agentengine/)
    - [ ] Verified/Tested (User Only)

### 3. Canary Releases & Advanced Rollouts
*   **Objective:** Implement **Canary Release** strategies across GKE and Cloud Run.
*   **Progress:**
    - [x] Approved Idea
    - [x] Developed (Templates/Docs) - See [templates/clouddeploy-canary.yaml](./templates/clouddeploy-canary.yaml)
    - [ ] Verified/Tested (User Only)

### 4. AI-Specific Testing & Evaluation (Vertex AI)
*   **Objective:** Integrate **Vertex AI Model Evaluation** and **Gen AI Evaluation** into the CI/CD pipeline.
*   **Progress:**
    - [x] Approved Idea
    - [x] Developed (Templates/Docs) - See [templates/eval-cloudbuild.yaml](./templates/eval-cloudbuild.yaml)
    - [ ] Verified/Tested (User Only)


### 5. Infrastructure as Code (Terraform)
*   **Objective:** Provide a comprehensive set of Terraform modules for enterprise environments.
*   **Progress:**
    - [x] Approved Idea
    - [ ] Developed (Templates/Docs)
    - [ ] Verified/Tested (User Only)

### 6. Automated Observability & Monitoring
*   **Objective:** Integrate out-of-the-box monitoring dashboards and alerting rules.
*   **Progress:**
    - [x] Approved Idea
    - [ ] Developed (Templates/Docs)
    - [ ] Verified/Tested (User Only)

---

## Contributing
We welcome open discussion on these topics. Please refer to the [instructions.md](./instructions.md) for the "Production-Grade" standards before proposing a new architecture.
