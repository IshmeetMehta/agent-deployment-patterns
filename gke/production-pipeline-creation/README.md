# GKE Production-Grade Agent Deployment Kit

This repository provides a standardized, "Senior-level" CI/CD pipeline template for deploying agents built with the [Google ADK](https://google.github.io/adk-docs/) to Google Kubernetes Engine (GKE).

## Overview
If you have been developing your agent locally using `adk web` and are ready to move to a production environment, this kit provides everything you need to scaffold a professional-grade pipeline on Google Cloud using **Cloud Build**, **Cloud Deploy**, and **Skaffold**.

## AI-Native Workflow
This repository is designed to be "AI-friendly." You can point an LLM (like Gemini) to this repository to autonomously generate your deployment infrastructure.

**Sample Prompt for Gemini:**
```text
I have created an agent and it's working fine local, using adk web, the agent is located inside the agent folder
Now I want to deploy it on GKE, but I don't have the cluster and you also need to create it and the infra related
Use the instructions.md as a main instructions and best practices
Create everything, but do not execute, I want to check everything before run
```

*Note: You can point the AI to this specific branch/repo: `https://github.com/IshmeetMehta/agent-deployment-patterns/tree/prod-pipeline`*

## Repository Structure
*   `instructions.md`: The foundational "Source of Truth" for deployment best practices and implementation steps.
*   `templates/`: Parametrized manifests for Kubernetes, Cloud Build, Cloud Deploy, and Skaffold.
*   `pipeline.md`: A visual and technical architecture of the 3-stage (Infra, CI, CD) pipeline.
*   [manual.md](./manual.md): A step-by-step guide for developers who prefer to configure the pipeline manually.

## Key Features
*   **Immutable Multi-Cluster Strategy:** Isolated `dev`, `qa`, and `prod` clusters ensure environment parity.
*   **Automated Promotion:** Successful deployments to Dev are automatically promoted to QA using Cloud Deploy Automation.
*   **Environment Verification:** Automated "smoke tests" using Alpine Linux containers via Skaffold Verify.
*   **Security First:** Pre-configured for Workload Identity and IAM least-privilege.
