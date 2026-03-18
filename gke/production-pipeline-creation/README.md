# GKE Production-Grade Agent Deployment Kit

This repository provides standardized, **production-grade** CI/CD pipeline templates for deploying agents built with the [Google ADK](https://google.github.io/adk-docs/) to Google Kubernetes Engine (GKE). It is centered around a robust 3-stage architecture (Infrastructure, CI, and CD) detailed in our [pipeline.md](./pipeline.md).

## Overview
If you have been developing your agent locally using `adk web` and are ready to move to a production environment, this kit provides everything you need to scaffold a professional pipeline on Google Cloud using **Cloud Build**, **Cloud Deploy**, and **Skaffold**.

### Deployment Options
You can choose between two deployment paths:
1.  **AI-Native Workflow creation:** Leverage LLMs (like Gemini) to autonomously generate your infrastructure and manifests using our specialized [instructions.md](./instructions.md).
2.  **Manual Configuration:** Follow our step-by-step [manual.md](./manual.md) to customize and apply the [templates/](./templates/) yourself.

## AI-Native Workflow creation
This repository is designed to be "AI-friendly." You can point an LLM (like Gemini) to this repository to autonomously generate your deployment infrastructure.

**Sample Prompt for Gemini:**
```text
I have created an agent and it's working fine locally, using adk web, the agent is located inside the agent folder
Now I want to deploy it on GKE, but I don't have the cluster and you need to create it and all the infra related
Use the file below as a main instruction and best practices and consider other files inside the same repo
https://github.com/IshmeetMehta/agent-deployment-patterns/blob/prod-pipeline/gke/production-pipeline-creation/instructions.md
Create all files, scripts and manifests, but do not execute, I want to check everything before run
```

*Note: You can point the AI to this specific branch/repo:*
`https://github.com/IshmeetMehta/agent-deployment-patterns/tree/prod-pipeline`

## Repository Structure
*   [instructions.md](./instructions.md): The foundational "Source of Truth" for deployment best practices and implementation steps.
*   [pipeline.md](./pipeline.md): A visual and technical architecture of the 3-stage (Infra, CI, CD) pipeline.
*   [event-driven-cd.md](./event-driven-cd.md): Detailed guide for the asynchronous, Eventarc-driven deployment strategy.
*   [manual.md](./manual.md): A step-by-step guide for developers who prefer to configure the pipeline manually.
*   [security.md](./security.md): Security guardrails and DevSecOps best practices for agents.
*   [prompt-to-generate-files.md](./prompt-to-generate-files.md): Detailed variable mapping and hydration logic for the **GKE (Primary Target)** templates.
*   [next-steps.md](./next-steps.md): Roadmap for future enhancements and platform expansions.
*   [templates/](./templates/): **Production-Grade Templates**
    *   **GKE (Primary Target):** Core manifests for GKE (Deployment, Service, KSA, etc.) are located in the root of this directory.
    *   [cloudrun/](./templates/cloudrun/): Specialized templates and [prompt-to-generate-files-cloudrun.md](./templates/cloudrun/prompt-to-generate-files-cloudrun.md) for serverless deployments.
    *   [agentengine/](./templates/agentengine/): Specialized templates and [prompt-to-generate-files-agentengine.md](./templates/agentengine/prompt-to-generate-files-agentengine.md) for Agent Engine lifecycle management.

## Key Features
*   **Immutable Multi-Cluster Strategy:** Isolated `dev`, `qa`, and `prod` clusters ensure environment parity.
*   **Automated Promotion:** Successful deployments to Dev are automatically promoted to QA using Cloud Deploy Automation.
*   **Environment Verification:** Automated "smoke tests" using Alpine Linux containers via Skaffold Verify.
*   **Security First:** Pre-configured for Workload Identity and IAM least-privilege.
