# 6. Docker, Azure Container Registry & Application Containers

## 6.1 Overview

The application layer is containerized using Docker and deployed to
Azure Kubernetes Service (AKS).

Azure Container Registry (ACR) is used as the private registry for
container images.

The overall application container flow is:

```text
Application Source
       |
       v
Docker Build
       |
       v
Container Image
       |
       v
Azure Container Registry
       |
       v
Azure Kubernetes Service
       |
       v
Kubernetes Pod
       |
       v
Running Application
```

---

## 6.2 Docker

Docker is used to package application code, runtime dependencies,
and required libraries into portable container images.

The basic container build lifecycle is:

```text
Dockerfile
    |
    v
docker build
    |
    v
Container Image
```

The resulting image provides a consistent deployment artifact for
the application.

---

## 6.3 Azure Container Registry

Azure Container Registry provides a private registry for storing
application container images.

The image flow is:

```text
Docker
  |
  v
Container Image
  |
  v
Azure Container Registry
```

ACR is integrated with AKS so that Kubernetes workloads can pull the
required private images.

---

## 6.4 ACR and AKS Integration

AKS requires permission to pull private container images from ACR.

The identity-based access model is:

```text
AKS Kubelet Identity
        |
        | AcrPull
        v
Azure Container Registry
        |
        v
Container Image
```

The project uses Azure RBAC rather than embedding long-lived registry
credentials directly into Kubernetes workloads.

The `AcrPull` role provides the required permission for the AKS
identity to pull images from the registry.

---

## 6.5 Container Deployment

Once an image is available in ACR, Kubernetes Deployments reference
the required image.

Conceptually:

```yaml
containers:
  - name: backend
    image: <acr-name>/backend:<tag>
```

Kubernetes then creates the required Pods through the Deployment
controller.

The deployment relationship is:

```text
Deployment
    |
    v
ReplicaSet
    |
    v
Pod
    |
    v
Container
```

The same model can be used for the frontend workload.

---

## 6.6 Frontend and Backend Containers

The application tier contains separate frontend and backend workloads.

```text
AKS
 |
 +-- Frontend
 |      |
 |      +-- Frontend Pods
 |
 +-- Backend
        |
        +-- Backend Pods
                |
                v
             Azure SQL
```

Separating frontend and backend workloads allows them to be deployed,
scaled, updated, and managed independently.

The backend is responsible for application/API processing and
communication with the database tier.

---

## 6.7 Kubernetes Services

Kubernetes Services provide stable network endpoints for application
workloads.

The conceptual model is:

```text
Frontend Service
       |
       v
Frontend Pods


Backend Service
       |
       v
Backend Pods
```

Services prevent external components from depending directly on
individual ephemeral Pod IP addresses.

The Service selects the appropriate Pods using Kubernetes labels.

---

## 6.8 Application Gateway to AKS

Application Gateway provides the external application entry point.

The application traffic flow is:

```text
Internet
   |
   | HTTPS :443
   v
Application Gateway + WAF
   |
   v
AGIC-managed configuration
   |
   v
Kubernetes Ingress
   |
   v
Kubernetes Service
   |
   v
Application Pods
```

Application Gateway handles the external Layer-7 traffic while
Application Gateway Ingress Controller (AGIC) synchronizes Kubernetes
Ingress configuration with Application Gateway.

AGIC watches Kubernetes Ingress resources and updates the Application
Gateway configuration accordingly.

---

## 6.9 Container Security

Container images are stored in a private Azure Container Registry.

AKS accesses the registry using Azure identity and RBAC.

The security model is:

```text
AKS
 |
 | Managed Identity / Kubelet Identity
 |
 | AcrPull
 v
Azure Container Registry
 |
 v
Private Container Image
```

This avoids storing long-lived registry credentials directly inside
Kubernetes application configuration.

Additional security controls are provided by the wider platform,
including:

- Azure RBAC
- Managed Identities
- Network Security Groups
- Application Gateway WAF
- Private connectivity
- Key Vault
- Controlled outbound connectivity

The exact controls used by the application deployment should match
the project's actual implementation.

---

## 6.10 Container Lifecycle

The overall application container lifecycle is:

```text
Developer
    |
    v
Application Source
    |
    v
Dockerfile
    |
    v
Docker Build
    |
    v
Container Image
    |
    v
Azure Container Registry
    |
    v
AKS Deployment
    |
    v
Kubernetes ReplicaSet
    |
    v
Kubernetes Pod
    |
    v
Running Container
    |
    v
Running Application
```

This provides a repeatable path from application source code to a
running containerized workload.

---

## 6.11 CI/CD Integration

The container workflow integrates with the Azure DevOps DevSecOps
delivery process.

The high-level pipeline architecture is:

```text
Source Code
    |
    v
Azure DevOps
    |
    +--> Build
    |
    +--> Test
    |
    +--> Docker Build
    |
    +--> Image Push
    |
    v
Azure Container Registry
    |
    v
Azure Kubernetes Service
    |
    v
Kubernetes Deployment
```

The validated container image is pushed to ACR and then referenced by
the Kubernetes deployment.

The exact pipeline stages and tasks are documented separately in the
Azure DevOps / CI/CD documentation.

---

## 6.12 End-to-End Container Deployment Flow

The complete application container delivery flow can be summarized as:

```text
                    APPLICATION DELIVERY

Developer
    |
    v
Source Code
    |
    v
Azure DevOps Pipeline
    |
    +--> Build
    |
    +--> Test
    |
    +--> Docker Build
    |
    v
Container Image
    |
    v
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
ReplicaSet
    |
    v
Pods
    |
    +-------------------+
    |                   |
    v                   v
Frontend             Backend/API
                        |
                        v
                     Azure SQL
```

---

## 6.13 Runtime Traffic Flow

Once the containers are deployed, application traffic follows the
runtime path below:

```text
Internet
   |
   | HTTPS :443
   v
Public IP
   |
   v
Application Gateway
   |
   v
WAF
   |
   v
Path-Based Routing
   |
   +--------------------+
   |                    |
   | /                  | /api/*
   v                    v
Frontend Service     Backend Service
   |                    |
   v                    v
Frontend Pods        Backend Pods
                         |
                         v
                      Azure SQL
```

Application Gateway therefore acts as the external ingress point,
while Kubernetes Services provide stable internal endpoints for the
frontend and backend workloads.

---

## 6.14 Container and Infrastructure Separation

The project separates infrastructure provisioning from application
container deployment.

### Infrastructure

```text
Terraform
    |
    v
Azure Infrastructure
    |
    +--> VNet
    +--> Subnets
    +--> AKS
    +--> Application Gateway
    +--> ACR
    +--> Azure SQL
    +--> Key Vault
    +--> Storage
    +--> Monitoring
```

### Application

```text
Application Source
    |
    v
Docker
    |
    v
Container Image
    |
    v
ACR
    |
    v
AKS
    |
    v
Kubernetes Pods
```

This separation allows infrastructure and application delivery to be
managed independently while still being integrated through the DevSecOps
pipeline.

---

## 6.15 Validation

The container deployment should be validated at multiple levels.

### Container Image

Confirm that the required image exists in ACR.

```text
ACR
 |
 +--> Frontend Image
 |
 └--> Backend Image
```

### Kubernetes Workloads

Confirm that the expected workloads and Pods are running:

```text
Deployment
    |
    v
Pods
    |
    v
Running Containers
```

### Kubernetes Services

Confirm that Services select the expected Pods.

```text
Service
   |
   v
Pod Endpoints
```

### Application Connectivity

Validate the complete request path:

```text
Client
   |
   v
Application Gateway
   |
   v
Kubernetes Service
   |
   v
Application Pod
   |
   v
Application Response
```

Where applicable, Application Gateway access logs, Kubernetes logs,
Pod status, Service endpoints, and application responses can be used
as evidence of successful deployment.

---

## 6.16 Key Takeaways

The container architecture demonstrates:

- Docker-based application packaging
- Private container image storage in Azure Container Registry
- Azure RBAC-based ACR access
- AKS-based container orchestration
- Separate frontend and backend workloads
- Kubernetes Deployments and ReplicaSets
- Stable Kubernetes Services
- Application Gateway and WAF as the external ingress layer
- AGIC integration with Kubernetes Ingress
- Azure DevOps integration for container CI/CD
- Separation of infrastructure provisioning and application delivery

The overall relationship is:

```text
Docker
   |
   v
Container Image
   |
   v
Azure Container Registry
   |
   | AcrPull
   v
AKS
   |
   v
Kubernetes Deployment
   |
   v
Pods
   |
   +------------+
   |            |
   v            v
Frontend     Backend
                |
                v
             Azure SQL
```
