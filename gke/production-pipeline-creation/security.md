# Security Guardrails & DevSecOps for Agents

This document details the security layers and DevSecOps best practices for agents deployed on Google Kubernetes Engine (GKE). Our goal is to ensure end-to-end security, from the source code to the production clusters.

## 1. Infrastructure & Organization Level

Security begins at the Google Cloud organization and project level. We recommend the following guardrails:

*   **Model Armor:** Use [Google Cloud Model Armor](https://cloud.google.com/model-armor/docs) to manage and monitor AI model usage across the organization. This provides centralized visibility and control over model access and data safety.
*   **VPC Service Controls (VPC-SC):** Configure VPC-SC to create a security perimeter around sensitive services like Vertex AI, GKE, and Artifact Registry, preventing data exfiltration.
*   **Cloud Armor:** Deploy Google Cloud Armor in front of the agent's external Ingress or LoadBalancer to protect against DDoS attacks and OWASP Top 10 vulnerabilities.
*   **Organization Policies:** Enforce project-level policies like `constraints/compute.disableExternalIP` and `constraints/container.restrictVPCInternal` to limit the exposure of agent infrastructure.

## 2. CI/CD Phase Security (DevSecOps)

The CI/CD pipeline is the most critical point for security checks. We recommend integrating these steps into the **Cloud Build** lifecycle:

### 2.1. Code-Level Security
*   **Safety Filters:** Implement and evaluate the Vertex AI [Safety Filters](https://cloud.google.com/vertex-ai/docs/generative-ai/multimodal/configure-safety-attributes) directly in the agent's code. This ensures the model outputs align with responsible AI guidelines.
*   **Static Application Security Testing (SAST):** Integrate tools like [SonarQube](https://www.sonarqube.org/) into the CI phase to identify code-level vulnerabilities, secret leakage, and code smells.
*   **Vulnerability Scanning:** Enable [Artifact Registry Vulnerability Scanning](https://cloud.google.com/artifact-registry/docs/analysis/vulnerability-scanning) to automatically scan Docker images for OS and package vulnerabilities upon push.

### 2.2. Dynamic Security Testing
*   **Dynamic Application Security Testing (DAST):** Integrate tools like [OWASP ZAP](https://www.zaproxy.org/) into the **Skaffold Verify** stage to perform automated security scans against the running agent in the `dev` or `qa` cluster.
*   **Content Filtering Evaluation:** During the CI phase, run scripts that evaluate the agent's resilience to prompt injection and other adversarial attacks, potentially using tools like [Giskard](https://www.giskard.ai/) or custom evaluation scripts with the Vertex AI SDK.

## 3. Runtime Security (GKE)

*   **GKE Sandbox (gVisor):** Use [GKE Sandbox](https://cloud.google.com/kubernetes-engine/docs/concepts/sandbox-overview) (based on gVisor) to provide a secure kernel boundary for agent pods. This provides an additional layer of isolation, which is critical when agents process untrusted user prompts or execute dynamic code. To enable it, specify `runtimeClassName: gvisor` in your pod spec.
*   **Pod Snapshots (Context Forensics):** When a security event is detected within a sandboxed environment, leverage [VolumeSnapshots](https://cloud.google.com/kubernetes-engine/docs/how-to/volume-snapshots) to capture a point-in-time state of the pod's filesystem and context. This allows security teams to analyze the attack vector in a forensic environment without keeping the compromised pod running.
*   **Workload Identity Sameness:** Use the pre-configured [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) to ensure the agent's KSA only has the minimum necessary IAM permissions (Least Privilege).
*   **Policy Controller:** Use [GKE Policy Controller](https://cloud.google.com/kubernetes-engine/docs/how-to/policy-controller) to enforce security policies (e.g., PSP-like policies) on every manifest that is applied to the cluster.
*   **Binary Authorization:** Implement [Binary Authorization](https://cloud.google.com/binary-authorization/docs) to ensure that only images signed and verified by the CI/CD pipeline can be deployed to the production cluster.

## 4. References & Documentation
*   [Google Cloud Security Foundations Guide](https://cloud.google.com/architecture/security-foundations)
*   [Securing GKE Clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)
*   [Vertex AI Responsible AI Documentation](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/responsible-ai)
