# 2. Architecture & Resource Design

## 2.1 Architecture Overview

The Enterprise 3-Tier DevSecOps platform is designed as a secure, multi-layer Azure architecture.

The platform separates application traffic, Kubernetes workloads, private Azure services, outbound connectivity, security controls, monitoring responsibilities, and infrastructure provisioning.

The major architectural layers are:

1. **Internet / Client Layer**
2. **Application Delivery Layer**
3. **Application / Kubernetes Layer**
4. **Data and Platform Services Layer**
5. **Network Security Layer**
6. **Monitoring and Observability Layer**
7. **Infrastructure as Code Layer**

---

## 2.2 High-Level Architecture

```text
                                      INTERNET
                                         |
                                         | HTTPS :443
                                         v
                              +----------------------+
                              |     Azure Public IP  |
                              +----------+-----------+
                                         |
                                         v
                              +----------------------+
                              |  Azure Application   |
                              |       Gateway        |
                              |       WAF v2         |
                              |                      |
                              |  HTTPS Listener      |
                              |  Routing Rules       |
                              |  Backend Pools       |
                              |  Health Probes       |
                              +----------+-----------+
                                         |
                                         | Application Traffic
                                         v
        +------------------------------------------------------------------+
        |                         AZURE VIRTUAL NETWORK                     |
        |                                                                  |
        |  +--------------------------+                                    |
        |  | Application Gateway      |                                    |
        |  | Subnet                   |                                    |
        |  +--------------------------+                                    |
        |                                                                  |
        |  +------------------------------------------------------------+  |
        |  |                        AKS Subnet                           |  |
        |  |                                                            |  |
        |  |   +------------------+       +------------------+           |  |
        |  |   |  Frontend Pods   |       |  Backend Pods    |           |  |
        |  |   +------------------+       +--------+---------+           |  |
        |  |                                      |                     |  |
        |  +--------------------------------------|---------------------+  |
        |                                         |                        |
        |                                         | Private Connectivity  |
        |                                         v                        |
        |  +--------------------------+     +-------------------------+   |
        |  | Private Endpoint Subnet  |     | Private Endpoint         |   |
        |  |                          |---->| for Azure Services       |   |
        |  +--------------------------+     +------------+------------+   |
        |                                                    |             |
        +----------------------------------------------------|-------------+
                                                             |
                                      +----------------------+----------------+
                                      |                      |                |
                                      v                      v                v
                                Azure SQL              Key Vault          Storage
                             Private Access        Private Access      Private Access


                              OUTBOUND CONNECTIVITY
                                      |
                                      v
                                NAT Gateway
                                      |
                                      v
                              Static Public IP
                                      |
                                      v
                                   INTERNET
```

---

## 2.3 Application Traffic Flow

The application follows a three-tier traffic flow:

```text
Internet
   |
   | HTTPS :443
   v
Application Gateway
   |
   +--> WAF v2
   |
   +--> HTTPS Listener
   |
   +--> Path-Based Routing
   |
   +------------+-------------+
   |                          |
   | /                        | /api/*
   v                          v
Frontend                   Backend/API
                              |
                              v
                         Azure SQL
```

Application Gateway acts as the public Layer-7 entry point and provides:

* HTTPS termination
* WAF inspection
* Path-based routing
* Backend pools
* Health probes
* Backend HTTP settings

---

## 2.4 Azure Virtual Network

The Azure Virtual Network provides the private network boundary for the platform.

The VNet contains dedicated subnets for different infrastructure components.

```text
Azure Virtual Network
│
├── Application Gateway Subnet
│      └── Application Gateway
│
├── AKS Subnet
│      ├── Frontend Workloads
│      └── Backend Workloads
│
└── Private Endpoint Subnet
       ├── Azure SQL Private Endpoint
       ├── Key Vault Private Endpoint
       └── Storage Private Endpoint
```

This subnet separation provides logical isolation between the application delivery layer, Kubernetes workloads, and private Azure service connectivity.

---

## 2.5 Application Gateway Subnet

The Application Gateway is deployed into a dedicated subnet:

```text
snet-appgw
    |
    └── Azure Application Gateway
          |
          └── WAF v2
```

The subnet is dedicated to Application Gateway infrastructure and separates the public application delivery layer from the AKS workload subnet.

---

## 2.6 AKS Subnet

The AKS cluster is deployed into the dedicated AKS subnet:

```text
snet-aks
    |
    +── Frontend Workloads
    |
    └── Backend/API Workloads
```

The application workloads are containerized and run as Kubernetes Pods.

The logical application structure is:

```text
AKS
 |
 +------------------+
 |                  |
 v                  v
Frontend         Backend/API
                    |
                    v
                Azure SQL
```

---

## 2.7 Private Endpoint Subnet

Private Endpoints provide private connectivity from the Azure VNet to supported Azure PaaS services.

The architecture separates the Private Endpoint subnet from the Application Gateway and AKS subnets.

```text
Private Endpoint Subnet
        |
        +---- Azure SQL
        |
        +---- Azure Key Vault
        |
        └---- Azure Storage
```

The logical connectivity is:

```text
AKS / VNet
    |
    v
Private Endpoint
    |
    v
Azure PaaS Service
```

This allows supported Azure services to be accessed through private network connectivity rather than relying on public endpoints.

---

## 2.8 Outbound Connectivity

NAT Gateway provides controlled and predictable outbound internet connectivity for resources associated with the AKS subnet.

The outbound flow is:

```text
AKS Workloads
      |
      v
NAT Gateway
      |
      v
Static Public IP
      |
      v
Internet
```

The NAT Gateway is used for **outbound** connectivity.

It is not part of the inbound Application Gateway traffic path.

### Inbound

```text
Internet
   |
   v
Public IP
   |
   v
Application Gateway
   |
   v
AKS
```

### Outbound

```text
AKS
   |
   v
NAT Gateway
   |
   v
Static Public IP
   |
   v
Internet
```

---

## 2.9 Network Security

Network-level security is implemented through Azure networking controls.

The architecture includes:

* Network Security Groups (NSGs)
* Route Tables / User Defined Routes
* NAT Gateway
* Private Endpoints
* Application Gateway WAF

Conceptually:

```text
Internet
   |
   v
Application Gateway
   |
   v
WAF
   |
   v
NSG / Network Controls
   |
   v
AKS
   |
   v
Private Azure Services
```

The specific NSG rules and route definitions are documented separately in the networking documentation.

---

## 2.10 Data and Platform Services

The platform uses Azure-managed services alongside AKS.

### Azure SQL

Azure SQL provides the database tier:

```text
Backend/API
     |
     v
Private Connectivity
     |
     v
Azure SQL
```

### Azure Key Vault

Key Vault is used as a secure platform service for application and infrastructure secrets.

```text
Application / Azure Resources
          |
          v
      Key Vault
```

### Azure Storage

Azure Storage provides platform storage capabilities and is accessed through the configured Azure networking architecture.

```text
Application / Azure Resources
          |
          v
       Storage
```

---

## 2.11 Infrastructure as Code

The Azure infrastructure is provisioned and managed using Terraform.

Terraform is responsible for creating and managing the infrastructure components required by the platform.

The logical provisioning flow is:

```text
Terraform
    |
    v
Azure Resources
    |
    +── VNet
    +── Subnets
    +── NSGs
    +── Route Tables
    +── NAT Gateway
    +── Application Gateway
    +── AKS
    +── Private Endpoints
    +── Key Vault
    +── Storage
    +── Azure SQL
    +── Monitoring
```

Terraform is organized into reusable modules for major infrastructure components.

---

## 2.12 Monitoring and Observability

Azure-native monitoring provides visibility across the platform.

The monitoring architecture is:

```text
Azure Resources
      |
      v
Azure Monitor
      |
      +---- Logs
      |
      +---- Metrics
      |
      +---- Diagnostic Settings
      |
      +---- KQL Queries
      |
      +---- Alerts
                |
                v
           Action Group
                |
                v
              Email
```

The monitored resources include:

* Application Gateway
* WAF
* AKS
* Azure SQL
* Key Vault
* Other configured Azure resources

Logs and metrics are centralized through the configured monitoring architecture and can be analyzed using Log Analytics and KQL.

---

## 2.13 Overall Architecture Flow

The complete platform can be summarized as:

```text
                              DEVELOPER
                                  |
                                  v
                             Azure DevOps
                                  |
                                  v
                              Terraform
                                  |
                                  v
                         Azure Infrastructure
                                  |
             +--------------------+--------------------+
             |                    |                    |
             v                    v                    v
            VNet                 AKS             Azure Services
             |                    |                    |
             |             +------+-------+            |
             |             |              |            |
             |             v              v            |
             |         Frontend       Backend          |
             |                            |             |
             |                            v             |
             |                        Azure SQL <-------+
             |
             +--> Application Gateway + WAF
             |
             +--> Private Endpoints
             |
             +--> NSGs / UDR
             |
             +--> NAT Gateway


Internet
   |
   | HTTPS :443
   v
Public IP
   |
   v
Application Gateway + WAF
   |
   v
AKS
   |
   +--> Frontend
   |
   └--> Backend/API
          |
          v
       Azure SQL


Monitoring:

Azure Resources
      |
      v
Azure Monitor
      |
      +--> Logs
      +--> Metrics
      +--> Diagnostics
      +--> Alerts
               |
               v
          Action Group
               |
               v
             Email
```

---

## 2.14 Architecture Summary

The platform uses a layered architecture in which each component has a defined responsibility:

| Layer                | Primary Components                   | Responsibility                             |
| -------------------- | ------------------------------------ | ------------------------------------------ |
| Internet / Client    | Internet, Public IP                  | External client access                     |
| Application Delivery | Application Gateway, WAF             | HTTPS termination, security and routing    |
| Kubernetes           | AKS, Frontend, Backend               | Application workloads                      |
| Data                 | Azure SQL                            | Database services                          |
| Platform             | Key Vault, Storage                   | Supporting Azure services                  |
| Private Connectivity | Private Endpoints                    | Private access to Azure services           |
| Network Security     | NSGs, UDR, NAT Gateway               | Traffic control and outbound connectivity  |
| Infrastructure       | Terraform                            | Infrastructure provisioning and management |
| Monitoring           | Azure Monitor, Log Analytics, Alerts | Observability and alerting                 |

This separation provides a structured architecture for application delivery, workload isolation, private service connectivity, controlled outbound traffic, security, infrastructure automation, and monitoring.
