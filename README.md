# End-to-End DevOps Project: Azure Voting App (CI/CD + GitOps)

## 📖 Project Overview
This repository hosts the **DevOps configuration and Infrastructure-as-Code (IaC)** for a 3-Tier Microservices Voting Application. 

While the application logic follows the standard [Docker Example Voting App](https://github.com/dockersamples/example-voting-app) architecture, this project focuses on the **implementation of a production-ready CI/CD pipeline** using Azure Cloud resources and GitOps principles.

## 🚀 Architecture & Workflow

The project implements a full **Code-to-Cloud** pipeline:

1.  **Code Commit:** Changes pushed to Azure Repos trigger the CI pipeline.
2.  **Continuous Integration (Azure Pipelines):**
    * Builds Docker images for `Vote`, `Result`, and `Worker` services.
    * Pushes tagged images to **Azure Container Registry (ACR)**.
    * **Automated Manifest Update:** A custom Bash script updates the Kubernetes manifest files in the repo with the new image tags.
3.  **Continuous Delivery (ArgoCD):**
    * ArgoCD (running on AKS) detects the change in the Git repository.
    * Automatically syncs the **Azure Kubernetes Service (AKS)** cluster to match the new configuration.

## 🛠️ Tech Stack & Tools Used

* **Cloud Provider:** Microsoft Azure
* **Containerization:** Docker & Docker Compose 
* **Orchestration:** Azure Kubernetes Service (AKS) 
* **CI/CD:** Azure DevOps (Pipelines & Repos)
* **GitOps Controller:** ArgoCD 
* **Registry:** Azure Container Registry (ACR) 
* **Scripting:** Bash (for automated manifest versioning) 

## 📂 Repository Structure

* `/vote`, `/result`, `/worker`: Application source code (Python/Node.js) and contains the `updateK8sManifests.sh` script used by the pipeline to update image tags.
* `/k8s-specifications`: Kubernetes manifest files (Deployments, Services) monitored by ArgoCD.
* `azure-pipelines.yaml`: CI pipeline definitions for building and pushing artifacts.

## ⚙️ Key Implementation Details

### 1. The CI Pipeline
I utilized **Self-Hosted Agents** on Linux Azure VMs to run the pipelines, ensuring faster builds and better resource control. The pipeline includes a special stage to update the infrastructure repository:

```yaml
- stage: Update_bash_script
  displayName: update_Bash_script
  jobs:
    - job: Updating_repo_with_bash
      displayName: updating_repo_using_bash_script
      steps:
      # FIX 1: Convert line endings from Windows (CRLF) to Linux (LF)
      - script: |
          sed -i 's/\r$//' vote/updateKubernetesManifests.sh
        displayName: 'Fix Windows Line Endings'

      # FIX 2: Run the script with the Token and Registry URL
      - task: ShellScript@2
        inputs:
          scriptPath: 'vote/updateKubernetesManifests.sh'
          # Added $(containerRegistry) as the 4th argument so the script knows the full URL
          args: 'vote $(imageRepository) $(tag) $(containerRegistry)'
        env:
          # This securely passes the permission to push code without hardcoding passwords
          AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
