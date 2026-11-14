# 7. AKS & Kubernetes

## 7.1 Overview

Azure Kubernetes Service (AKS) provides the container orchestration
layer for the application.

The application runs as Kubernetes workloads inside the AKS cluster.

The main runtime flow is:

```text
Application Gateway
       |
       v
AGIC
       |
       v
Kubernetes Ingress
       |
       +----------+
       |          |
       v          v
   Frontend    Backend
      |           |
      v           v
  Pods          Pods
                  |
                  v
              Azure SQL


              7.2 AKS Cluster

The development cluster is:

aks-enterprise-dev

The cluster is deployed into the Azure networking architecture and
uses the dedicated AKS subnet.

7.3 AKS Networking

The AKS network architecture is:

Azure VNet
    |
    v
AKS Subnet
    |
    v
AKS Nodes
    |
    v
Kubernetes Pods

The AKS subnet is associated with the NAT Gateway to provide
controlled outbound internet connectivity.

AKS
 |
 v
AKS Subnet
 |
 v
NAT Gateway
 |
 v
Static Public IP
 |
 v
Internet
7.4 Kubernetes Workloads

The application is separated into frontend and backend workloads.

AKS
 |
 +-- Frontend
 |      |
 |      +-- Frontend Pods
 |
 +-- Backend
        |
        +-- Backend Pods

This provides separation between the presentation and API tiers.

7.5 Kubernetes Services

Kubernetes Services provide stable endpoints for application
workloads.

Frontend Service
       |
       v
Frontend Pods


Backend Service
       |
       v
Backend Pods

Services abstract the ephemeral Pod IP addresses from consumers.

7.6 Kubernetes Ingress

Kubernetes Ingress defines HTTP/HTTPS routing for the application.

The application routing model is:

enterpriseapitask.online/
        |
        v
Frontend


enterpriseapitask.online/api/*
        |
        v
Backend API

Path-based routing allows the frontend and API workloads to be
exposed through the same application endpoint.

7.7 Application Gateway Ingress Controller

Application Gateway Ingress Controller (AGIC) connects Kubernetes
Ingress resources to Azure Application Gateway.

The flow is:

Kubernetes Ingress
        |
        v
AGIC
        |
        v
Application Gateway

AGIC watches Kubernetes ingress configuration and updates
Application Gateway accordingly.

7.8 AGIC Validation

The AGIC deployment was validated using:

kubectl get pods -n kube-system

The AGIC Pod reached:

1/1 Running

AGIC logs also showed successful Application Gateway reconciliation:

BEGIN AppGateway deployment
Applied generated Application Gateway configuration
END AppGateway deployment

This confirmed that AGIC was successfully communicating with and
updating Application Gateway.

7.9 Application Gateway Backend Routing

The Application Gateway configuration generated through AGIC
included backend pools and HTTP settings for the Kubernetes
application workloads.

The API backend was observed routing to:

10.10.2.30:8080

The API routing rule used:

/api*

Therefore:

Client
  |
  v
Application Gateway
  |
  | /api*
  v
Backend Pool
  |
  v
10.10.2.30:8080
7.10 End-to-End Application Flow

The complete application flow is:

Internet
   |
   | HTTPS :443
   v
Application Gateway
   |
   v
WAF
   |
   v
HTTPS Listener
   |
   v
Path-Based Routing
   |
   +---- / ------> Frontend
   |
   +---- /api* --> Backend
                    |
                    v
                 Kubernetes
                    |
                    v
                 Backend Pod
                    |
                    v
                Azure SQL
7.11 Runtime Validation

The AKS node environment was validated using Kubernetes commands.

The validated node was in:

Ready

state and used:

Ubuntu 24.04.4 LTS
containerd

The Kubernetes cluster version observed during validation was:

v1.35.6
7.12 Managed Identities

Different identities are used for different responsibilities.

AGIC Identity
    |
    +-- Application Gateway / networking permissions


AKS Kubelet Identity
    |
    +-- Node-level Azure operations
    +-- ACR image pulling


Workload Identity
    |
    +-- Kubernetes workload authentication
         to Azure resources

These identities should not be treated as interchangeable.

7.13 Workload Identity

AKS was configured with OIDC and Workload Identity support:

oidc_issuer_enabled       = true
workload_identity_enabled = true

The authentication flow is:

Kubernetes Pod
      |
      v
Service Account
      |
      v
OIDC / Federated Identity
      |
      v
Microsoft Entra ID
      |
      v
Azure RBAC
      |
      v
Azure Resource

This avoids storing long-lived Azure credentials inside application
workloads.

7.14 Container Runtime

The AKS node uses containerd as the container runtime.

The container execution flow is:

Azure Container Registry
          |
          v
      Container Image
          |
          v
       containerd
          |
          v
       Kubernetes
          |
          v
           Pod
7.15 Health Checking

Application Gateway uses backend health probes to determine whether
backend targets are available.

Application Gateway
       |
       v
Health Probe
       |
       v
Backend

Healthy backends receive application traffic while unhealthy
backends can be removed from active routing.

7.16 AKS Monitoring

AKS is part of the overall Azure monitoring architecture.

AKS
 |
 v
Azure Monitor
 |
 v
Log Analytics
 |
 +-- Logs
 +-- Metrics
 +-- Alerts

Application Gateway diagnostics are also sent to the centralized
Log Analytics workspace.

7.17 AKS Summary

AKS provides the application runtime and container orchestration
layer.

The overall flow is:

Application Gateway
       |
       v
       WAF
       |
       v
      AGIC
       |
       v
Kubernetes Ingress
       |
       +----------+
       |          |
       v          v
   Frontend    Backend
                  |
                  v
              Azure SQL