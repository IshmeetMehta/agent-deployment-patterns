# Terraform for GKE Agent Deployment

This directory contains Terraform code to provision a Google Kubernetes Engine (GKE) cluster suitable for deploying containerized agents.

The configuration creates an **Autopilot GKE cluster**, which simplifies cluster management by automating node provisioning, scaling, and security. This is often a cost-effective and efficient choice for running agent workloads.

## Resources Created

- **VPC Network**: A dedicated Virtual Private Cloud (`google_compute_network`) for the cluster.
- **Subnet**: A subnet (`google_compute_subnetwork`) within the VPC with secondary IP ranges for Pods and Services.
- **GKE Autopilot Cluster**: A regional GKE cluster (`google_container_cluster`) with Workload Identity enabled. Workload Identity is the recommended method for allowing your agents running on GKE to securely access other Google Cloud services (like Vertex AI).
- **API Enablement**: Ensures the `container.googleapis.com` API is enabled.

## Prerequisites

1.  Terraform (version >= 1.0) installed.
2.  gcloud CLI installed and authenticated.
3.  Application Default Credentials configured for Terraform:
    ```sh
    gcloud auth application-default login
    ```

## How to Use

1.  **Create a configuration file**:
    Create a file named `terraform.tfvars` in this directory to specify your project details.

    ```hcl
    # terraform.tfvars
    project_id = "your-gcp-project-id"
    region     = "us-central1"
    ```

2.  **Initialize Terraform**:
    Run this command from within the `terraform` directory to download the necessary providers.

    ```sh
    terraform init
    ```

3.  **Review the plan**:
    See what resources Terraform will create.

    ```sh
    terraform plan
    ```

4.  **Apply the configuration**:
    This will create the GKE cluster and associated networking resources. The process can take 10-15 minutes.

    ```sh
    terraform apply
    ```

    Enter `yes` when prompted to confirm.

5.  **Connect to the cluster**:
    Once the `apply` command is complete, you can configure `kubectl` to connect to your new cluster using the gcloud CLI. This command uses the output values from Terraform.

    ```sh
    gcloud container clusters get-credentials $(terraform output -raw gke_cluster_name) --region $(terraform output -raw gke_cluster_location)
    ```

6.  **Verify connection**:
    ```sh
    kubectl cluster-info
    ```
    You can also check for Autopilot-managed nodes (you may not see any until you deploy a workload):
    ```sh
    kubectl get nodes
    ```

## Cleanup

To destroy all the resources created by this configuration, run the following command from the `terraform` directory:

```sh
terraform destroy
```

Enter `yes` when prompted.
