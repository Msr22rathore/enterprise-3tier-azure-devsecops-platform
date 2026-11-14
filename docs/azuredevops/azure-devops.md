# 9. Azure DevOps

## 9.1 Overview

Azure DevOps was used as the development, work-tracking, source-control, and CI/CD platform for the Enterprise 3-Tier DevSecOps project.

The main Azure DevOps components used in the project are:

- Azure Boards — planning and work tracking
- Azure Repos — Git-based source control
- Azure Pipelines — CI/CD automation
- Service Connections — controlled authentication from pipelines to Azure

The high-level relationship is:

```text
                         Azure DevOps
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
           Boards            Repos          Pipelines
             |                |                |
             |                |                +--> Build
             |                |                +--> Test
             |                |                +--> Docker Build
             |                |                +--> Push Image
             |                |                +--> Deploy
             |                |                       |
             |                |                       v
             |                |                      ACR
             |                |                       |
             |                |                       v
             |                |                      AKS
             |                |                       |
             +----------------+-----------------------+
                                                      |
                                                      v
                                                  Application
```

Azure DevOps therefore supports more than application deployment: it connects planning, source control, infrastructure automation, application delivery, and Azure integration.

---

## 9.2 Azure DevOps Project

The Azure DevOps Project acts as the central workspace for the DevOps lifecycle.

```text
Azure DevOps Organization
          |
          v
       Project
          |
    +-----+-----+
    |     |     |
 Boards Repos Pipelines
```

The project brings together:

- Source control
- Work tracking
- CI/CD
- Build and deployment automation
- Azure integrations

---

## 9.3 Azure Boards

Azure Boards was used to organize and track implementation work.

The work hierarchy is:

```text
Epic
  |
  v
Feature
  |
  v
User Story
  |
  v
Task
```

The project work was divided into technical areas such as:

```text
3-Tier DevSecOps Project
│
├── Networking
│   ├── VNet
│   ├── Subnets
│   ├── NSGs
│   ├── NAT Gateway
│   └── Private Endpoints
│
├── AKS
│   ├── Cluster
│   ├── Node Pool
│   ├── Workloads
│   └── AGIC
│
├── Application Gateway
│   ├── WAF
│   ├── HTTPS
│   ├── Routing
│   └── Health Probes
│
├── Security
│   ├── RBAC
│   ├── Managed Identity
│   └── Key Vault
│
└── Monitoring
    ├── Log Analytics
    ├── Diagnostics
    ├── Metrics
    ├── Alerts
    └── Action Groups
```

### Task Board

The Task Board provides a visual representation of work status:

```text
+--------------+--------------+--------------+
|    TO DO     | IN PROGRESS  |     DONE     |
+--------------+--------------+--------------+
| CI/CD        | AKS          | VNet         |
| Monitoring   | AGIC         | NSGs         |
| Security     |              | NAT Gateway  |
|              |              | App Gateway  |
+--------------+--------------+--------------+
```

The board connects planning with implementation by moving work from **To Do** through **In Progress** to **Done**.

> **Portfolio evidence:** Add a screenshot of the actual Azure Boards project, work items, and Task Board if available. Do not create simulated screenshots.

---

## 9.4 Azure Repos

Azure Repos provides Git-based source control for the project.

The development workflow is:

```text
Developer
   |
   v
Local Repository
   |
   +--> git add
   |
   +--> git commit
   |
   +--> git push
   |
   v
Azure Repos
   |
   v
Pipeline Trigger
```

The repository contains project components such as:

- Application code
- Terraform infrastructure code
- Kubernetes manifests
- Dockerfiles
- Pipeline YAML
- Documentation

A typical Git workflow is:

```bash
git status
git add .
git commit -m "description"
git push
```

A push to Azure Repos can trigger the CI/CD pipeline when the corresponding pipeline trigger is configured.

---

## 9.5 Repository Structure

The repository can be organized around the major project components:

```text
enterprise-3tier-devsecops/
│
├── app/
├── infra/
│   └── terraform/
├── k8s/
├── pipelines/
├── docs/
├── scripts/
├── Dockerfile
├── .gitignore
└── README.md
```

Use the actual repository structure in the final documentation if it differs from this layout.

---

## 9.6 Branching Strategy

Document only the branching strategy actually used by the project.

For example, if multiple feature branches were used:

```text
main
 |
 +-- feature/networking
 +-- feature/aks
 +-- feature/application-gateway
 +-- feature/monitoring
```

If the project used only `main`, document that instead. Do not claim a feature-branch or pull-request workflow unless it was actually used.

---

## 9.7 Service Connections

An Azure DevOps Service Connection provides a controlled authentication path between a pipeline and Azure resources.

The conceptual flow is:

```text
Azure Pipeline
      |
      v
Service Connection
      |
      v
Microsoft Entra / Azure Authentication
      |
      v
Azure Subscription / Resources
```

The service connection prevents credentials from being embedded directly in pipeline YAML or application source code.

### Security Principles

Do not store the following directly in source control or pipeline YAML:

- Passwords
- Client secrets
- Private keys
- Certificates containing private keys
- Subscription credentials

Service connections should use the minimum permissions required by the pipeline.

> The exact authentication mechanism and scope of the service connection should be documented from the actual Azure DevOps configuration rather than assumed.

---

## 9.8 Pipeline Agent / Agent Pool

Azure Pipelines executes jobs through an agent.

The conceptual architecture is:

```text
Pipeline
   |
   v
Agent Pool
   |
   v
Build Agent
   |
   +--> Git
   +--> Docker
   +--> Azure CLI
   +--> Other required tools
```

Document the actual agent pool and image used by the project. For example, if the project used a Microsoft-hosted Ubuntu agent, the pipeline YAML would contain the corresponding `vmImage` configuration.

---

## 9.9 Azure Pipelines

Azure Pipelines provides the automation engine for application delivery.

The high-level flow is:

```text
Azure Repos
    |
    v
Pipeline Trigger
    |
    v
Build
    |
    v
Test
    |
    v
Docker Build
    |
    v
Azure Container Registry (ACR)
    |
    v
Azure Kubernetes Service (AKS)
    |
    v
Application Pods
```

The exact stages and tasks should match the pipeline YAML used by the project.

---

## 9.10 Continuous Integration (CI)

Continuous Integration focuses on validating changes before deployment.

The application CI flow is:

```text
Developer Push
      |
      v
Source Checkout
      |
      v
Build
      |
      v
Test
      |
      v
Docker Build
```

CI helps identify problems such as:

- Build failures
- Test failures
- Dependency issues
- Container build failures
- Application code problems

Security scanning should be documented here only if a corresponding security tool or pipeline task was actually configured.

---

## 9.11 Docker Build

The pipeline builds the application container image from the project source and Dockerfile.

```text
Source Code
    |
    v
Dockerfile
    |
    v
Docker Build
    |
    v
Container Image
```

Conceptually:

```bash
docker build -t <image>:<tag> .
```

Use the actual image name and tagging strategy from the pipeline when documenting the implementation.

---

## 9.12 Azure Container Registry (ACR)

Azure Container Registry provides the container image registry used by the application delivery process.

The flow is:

```text
Azure DevOps Pipeline
        |
        v
   Docker Build
        |
        v
  Container Image
        |
        v
        ACR
        |
        v
       AKS
```

Conceptually, an image can be pushed using:

```bash
docker push <acr>/<image>:<tag>
```

The exact registry, repository, image name, and tag should match the actual pipeline configuration.

---

## 9.13 ACR to AKS

After the container image is available in ACR, AKS uses the configured identity and RBAC integration to pull the image.

```text
Azure Container Registry
          |
          | Image Pull
          v
         AKS
          |
          v
   Kubernetes Deployment
          |
          v
          Pods
```

The required registry permission should follow least-privilege principles, such as the appropriate image-pull permission for the AKS identity.

---

## 9.14 Continuous Delivery / Deployment (CD)

Continuous Delivery/Deployment takes the validated application artifact and deploys it to the target environment.

```text
Validated Container Image
          |
          v
         ACR
          |
          v
     AKS Deployment
          |
          v
      ReplicaSet
          |
          v
         Pods
          |
          v
 Services / Ingress
```

The key DevOps principle is to build the application artifact once and deploy that validated artifact rather than rebuilding different images for different environments.

---

## 9.15 Complete Application CI/CD Flow

```text
Developer
    |
    v
Azure DevOps
    |
    +------------------+------------------+
    |                  |                  |
    v                  v                  v
  Boards             Repos            Pipelines
                       |                  |
                       |                  +--> Build
                       |                  +--> Test
                       |                  +--> Docker Build
                       |                  +--> Push Image
                       |                  +--> Deploy
                       |                         |
                       |                         v
                       |                        ACR
                       |                         |
                       |                         v
                       |                        AKS
                       |                         |
                       |                         v
                       |                  Kubernetes Pods
                       |                         |
                       +-------------------------v
                                          Application
```

---

## 9.16 Terraform and Azure DevOps

Terraform is the Infrastructure as Code layer, while Azure DevOps provides the automation platform.

The infrastructure flow is:

```text
Azure Repos
    |
    v
Azure Pipeline
    |
    v
Terraform
    |
    +--> init
    +--> validate
    +--> plan
    +--> apply
    |
    v
Azure Infrastructure
```

Terraform manages infrastructure such as:

- Virtual Network and subnets
- Network Security Groups
- NAT Gateway
- AKS
- Application Gateway
- WAF
- ACR
- Azure SQL
- Storage
- Key Vault
- Log Analytics
- Monitoring and alerts

The exact resources should match the final Terraform implementation.

If Terraform was executed manually rather than through Azure Pipelines, document that fact instead of claiming a Terraform CI/CD pipeline.

---

## 9.17 Infrastructure Deployment vs Application Deployment

These are separate but related delivery paths.

### Infrastructure

```text
Terraform
   |
   v
Azure Infrastructure
```

### Application

```text
Docker
   |
   v
ACR
   |
   v
AKS
   |
   v
Kubernetes Workloads
```

### Runtime Ingress

```text
Internet
   |
   v
Application Gateway + WAF
   |
   v
AGIC / Kubernetes Ingress
   |
   v
AKS Workloads
```

Together:

```text
                         Azure DevOps
                              |
                    +---------+---------+
                    |                   |
                    v                   v
                Terraform             Docker
                    |                   |
                    v                   v
             Azure Infrastructure      ACR
                                        |
                                        v
                                       AKS
                                        |
                                        v
                              Application Gateway
                                        |
                                        v
                                      Users
```

---

## 9.18 Pipeline Variables and Configuration

Pipeline variables separate configuration from pipeline logic.

Examples include:

```text
ACR_NAME
IMAGE_NAME
IMAGE_TAG
AKS_CLUSTER
RESOURCE_GROUP
```

Environment-specific values should not be unnecessarily hardcoded.

Sensitive values should be stored using the appropriate Azure DevOps secret mechanism or Azure secret-management service rather than committed to Git.

---

## 9.19 Pipeline Triggers

Document only the trigger types actually configured in the project.

Common trigger types include:

```text
Git Push
   |
   v
Pipeline
```

or:

```text
Pull Request
   |
   v
Validation Pipeline
```

or a manual execution:

```text
Run Pipeline
   |
   v
Pipeline
```

The final documentation should match the actual pipeline YAML.

---

## 9.20 Pipeline Stages

The final documented stages should match the real pipeline.

For example, if the implemented pipeline contains the following stages:

```text
Build
  |
  v
Test
  |
  v
Docker Build
  |
  v
Push Image
  |
  v
Deploy to AKS
```

then those stages should be shown in the architecture and documentation.

Do not add stages such as security scanning, approval gates, or automated rollback unless they are actually configured and tested.

---

## 9.21 Pipeline Validation

After deployment, application availability should be validated from the application entry point through the backend workload.

The validation chain is:

```text
Pipeline
   |
   v
AKS
   |
   v
Application
   |
   v
Application Gateway
   |
   v
HTTPS
   |
   v
HTTP 200
```

For this project, the documented API validation path was:

```text
/api/tasks
    |
    v
Application Gateway
    |
    v
10.10.2.30:8080
    |
    v
HTTP 200
```

This provides evidence that the deployed application was reachable through the configured Application Gateway path.

---

## 9.22 Troubleshooting and Operational Validation

The project documentation includes an AGIC/RBAC troubleshooting scenario.

The troubleshooting sequence was:

```text
AGIC
 |
 v
Azure Permission Issue
 |
 v
Inspect Role Assignments
 |
 v
Identify Principal
 |
 v
Grant Required Permissions
 |
 v
Restart / Reconcile AGIC
 |
 v
Check Pod Status
 |
 v
Check AGIC Logs
 |
 v
Application Gateway Reconciliation
```

The AGIC logs were then used to verify that the generated Application Gateway configuration was applied.

This type of operational troubleshooting is useful portfolio evidence because it demonstrates investigation and remediation rather than only initial deployment.

---

## 9.23 CI/CD Security

The CI/CD implementation should follow these principles:

### Do not commit secrets

Never commit:

- Passwords
- Private keys
- Service principal secrets
- Certificates containing private keys
- `.pfx` files
- `.pem` private keys
- Other sensitive credentials

### Use controlled authentication

```text
Azure Pipeline
      |
      v
Service Connection
      |
      v
Azure
```

### Use least privilege

Azure RBAC permissions should be limited to the resources and actions required by each component.

### Protect container registry access

AKS should use its configured Azure identity and the required registry permission to pull images from ACR.

---

## 9.24 Git Ignore and Sensitive Files

Generated state, credentials, certificates, and other sensitive files should not be committed to source control.

Important Terraform exclusions include:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
```

Sensitive certificate/key files should also be excluded:

```gitignore
*.pem
*.key
*.pfx
*.p12
```

Environment files should be excluded where applicable:

```gitignore
.env
.env.*
```

A real project should also use appropriate secret-management mechanisms rather than relying only on `.gitignore`.

---

## 9.25 DevSecOps Lifecycle

The overall DevSecOps lifecycle is:

```text
PLAN
  |
  v
CODE
  |
  v
BUILD
  |
  v
TEST
  |
  v
SECURITY VALIDATION
  |
  v
PACKAGE
  |
  v
DEPLOY
  |
  v
MONITOR
```

Only the security tools and checks actually implemented in the pipeline should be listed under **Security Validation**.

---

## 9.26 Overall Azure DevOps Architecture

The complete Azure DevOps relationship with the Azure platform can be summarized as:

```text
                                  AZURE DEVOPS
                                       |
                 +---------------------+---------------------+
                 |                     |                     |
                 v                     v                     v
              BOARDS                 REPOS               PIPELINES
                 |                     |                     |
                 |                     |             +-------+-------+
                 |                     |             |               |
                 |                     |             v               v
                 |                     |          Application    Infrastructure
                 |                     |           Delivery       Automation
                 |                     |             |               |
                 |                     |             v               v
                 |                     |           Docker          Terraform
                 |                     |             |               |
                 |                     |             v               v
                 |                     |            ACR         Azure Infrastructure
                 |                     |             |
                 |                     |             v
                 |                     |            AKS
                 |                     |             |
                 |                     +-------------v
                 |                              Application
                 |                                   |
                 |                                   v
                 |                         Application Gateway
                 |                                   |
                 |                                   v
                 |                                  Users
                 |
                 +---- Plan / Track / Validate Work
```

---

## 9.27 Azure DevOps and the Complete Platform

Azure DevOps is one part of the overall Enterprise 3-Tier DevSecOps platform.

```text
Developer
    |
    v
Azure DevOps
    |
    +-----------------------+
    |                       |
    v                       v
Terraform                 Application
    |                       |
    v                       v
Azure Infrastructure       Docker
    |                       |
    |                       v
    |                      ACR
    |                       |
    |                       v
    |                      AKS
    |                       |
    +-----------------------+
            |
            v
Application Gateway + WAF
            |
            v
          Users
```

The platform is then observed through Azure Monitor and Log Analytics, while Azure RBAC, managed identities, private connectivity, NSGs, WAF, and controlled outbound connectivity provide the supporting security architecture.

---

## 9.28 GitHub Documentation and Evidence

For the GitHub project, include documentation and screenshots that represent the actual Azure DevOps implementation.

Recommended evidence:

1. Azure DevOps Project home
2. Azure Boards work items
3. Azure Boards Task Board
4. Azure Repos repository
5. Service Connection configuration (without exposing credentials)
6. Pipeline definition
7. Pipeline execution and stages
8. Successful build/test results
9. ACR image or repository evidence
10. AKS deployment evidence
11. Application Gateway/API validation

Do not expose credentials, secrets, private keys, tokens, connection strings, or other sensitive information in screenshots.

---

## 9.29 Summary

The Azure DevOps implementation connects project planning, source control, infrastructure automation, application containerization, registry management, Kubernetes deployment, and operational validation.

The core application delivery path is:

```text
Developer
   |
   v
Azure Repos
   |
   v
Azure Pipelines
   |
   +--> Build
   +--> Test
   +--> Docker Build
   +--> Push Image
   +--> Deploy
   |
   v
Azure Container Registry
   |
   v
Azure Kubernetes Service
   |
   v
Application Gateway + WAF
   |
   v
Application Users
```

The infrastructure path is:

```text
Azure Repos
   |
   v
Azure Pipelines / Terraform Workflow
   |
   v
Terraform
   |
   v
Azure Infrastructure
```

Together, these workflows form the project's infrastructure and application delivery model.
