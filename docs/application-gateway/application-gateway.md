# Application Gateway, WAF, AGIC and TLS/SSL Architecture

## 1. Overview

Azure Application Gateway acts as the **public entry point** for the application.

The platform uses:

* Azure Application Gateway
* Web Application Firewall (WAF) v2
* HTTPS listener on port `443`
* Path-based routing
* Backend pools
* Backend HTTP settings
* Health probes
* Application Gateway Ingress Controller (AGIC)
* Azure Kubernetes Service (AKS)
* Managed Identity and Azure RBAC
* Let's Encrypt / Certbot TLS certificate
* Azure Monitor and diagnostic logs

The complete inbound application flow is:

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
   +--> WAF v2
   |
   +--> HTTPS Listener
   |
   +--> Path-Based Routing
   |
   v
AGIC-managed Application Gateway configuration
   |
   v
Kubernetes Ingress
   |
   +------------+-------------+
   |                          |
   v                          v
Frontend                   Backend
                              |
                              v
                           AKS Pods
```

---

## 2. Application Gateway

The Application Gateway used in the project is:

```text
appgw-enterprise-dev
```

It is deployed in a dedicated Application Gateway subnet:

```text
VNet
│
├── snet-appgw
│      └── Application Gateway
│
└── snet-aks
       └── AKS
```

Application Gateway provides:

* Public application entry
* HTTPS termination
* WAF protection
* HTTP/HTTPS routing
* Backend pools
* Backend HTTP settings
* Health probes
* Path-based routing

Application Gateway is therefore the **front door of the application**.

---

## 3. WAF v2

The Application Gateway uses **WAF_v2**.

WAF provides application-layer protection before requests reach the AKS workloads.

```text
Internet
   |
   v
Application Gateway
   |
   v
WAF v2
   |
   v
Routing
   |
   v
AKS
```

The diagnostic data confirmed that WAF was operating in:

```text
Prevention
```

mode.

This means the WAF was configured to actively block requests that matched applicable protection rules rather than operating only in detection/monitoring mode.

---

## 4. Inbound vs Outbound Traffic

The Application Gateway public IP handles **inbound application traffic**.

### Inbound

```text
Internet
   |
   v
Application Gateway Public IP
   |
   v
Application Gateway
   |
   v
AKS
```

The NAT Gateway is **not part of this inbound path**.

### Outbound

NAT Gateway is used for controlled outbound connectivity:

```text
AKS
   |
   v
NAT Gateway
   |
   v
Internet
```

This distinction is important when troubleshooting Azure networking.

---

## 5. HTTPS and TLS

The Application Gateway exposes an HTTPS listener:

```text
Protocol: HTTPS
Port:     443
Host:     enterpriseapitask.online
```

The client-facing flow is:

```text
Client
   |
   | HTTPS :443
   v
Application Gateway
   |
   v
HTTPS Listener
   |
   v
Backend
```

Application Gateway access logs confirmed:

```text
sslEnabled_s  = on
sslProtocol_s = TLSv1.3
```

---

## 6. Custom Domain

The application uses the custom domain:

```text
enterpriseapitask.online
```

The external request is therefore:

```text
https://enterpriseapitask.online
```

The domain points toward the Application Gateway public endpoint.

---

## 7. Path-Based Routing

Application Gateway uses path-based routing to separate frontend and backend traffic.

### Frontend

```text
https://enterpriseapitask.online/
             |
             v
         Frontend
```

### Backend API

```text
https://enterpriseapitask.online/api/*
             |
             v
        Backend API
```

This allows both frontend and backend APIs to use the same domain.

---

## 8. Backend Pool

The backend configuration used port `8080`.

The API backend was routed to:

```text
10.10.2.30:8080
```

The traffic flow is:

```text
Application Gateway
       |
       v
Backend Pool
       |
       v
10.10.2.30
       |
       v
Port 8080
```

---

## 9. Backend HTTP Settings

The backend HTTP settings define how Application Gateway communicates with the backend.

The project configuration used:

```text
Protocol: HTTP
Port:     8080
```

Therefore, the client-facing and backend connections were different:

```text
Client
   |
   | HTTPS :443
   v
Application Gateway
   |
   | HTTP :8080
   v
Backend
```

This represents **TLS termination at Application Gateway**.

---

## 10. Health Probes

Application Gateway uses health probes to determine backend availability.

```text
Application Gateway
       |
       | Health Probe
       v
    Backend
       |
       +--> Healthy
       |       |
       |       v
       |    Receive traffic
       |
       +--> Unhealthy
               |
               v
          Do not route traffic
```

Health probes prevent Application Gateway from sending traffic to an unavailable backend.

---

# 11. Application Gateway Ingress Controller (AGIC)

## What is AGIC?

**Application Gateway Ingress Controller (AGIC)** is a Kubernetes controller running inside AKS.

It watches Kubernetes resources, particularly Ingress configuration, and translates the desired Kubernetes routing configuration into Application Gateway configuration.

Conceptually:

```text
Kubernetes
   |
   +--> Ingress
   +--> Services
   +--> Workloads
   |
   v
  AGIC
   |
   v
Application Gateway
   |
   +--> Listeners
   +--> Backend Pools
   +--> HTTP Settings
   +--> Routing Rules
   +--> Probes
```

AGIC is **not** the Application Gateway itself.

A useful way to remember it:

> **AGIC is the controller; Application Gateway is the traffic-handling infrastructure.**

---

## 12. Where AGIC Runs

AGIC runs as a Pod inside the AKS cluster.

```text
AKS Cluster
│
├── AGIC Pod
│
├── Frontend Pods
│
└── Backend Pods
```

The AGIC Pod communicates with Azure resources through Azure APIs.

---

# 13. Terraform vs AGIC Responsibilities

Terraform and AGIC have different responsibilities.

### Terraform

Terraform provisions the base Azure infrastructure:

```text
Terraform
   |
   +--> VNet
   +--> Subnets
   +--> Application Gateway
   +--> Public IP
   +--> WAF
   +--> Networking
   +--> RBAC
```

### AGIC

AGIC manages Kubernetes-driven Application Gateway configuration:

```text
AGIC
   |
   +--> Listeners
   +--> Backend Pools
   +--> HTTP Settings
   +--> Routing Rules
   +--> Kubernetes Ingress mappings
```

Therefore:

```text
Terraform
   |
   v
Base Azure Infrastructure

Kubernetes Ingress
   |
   v
AGIC
   |
   v
Application Gateway Routing Configuration
```

---

# 14. AGIC Reconciliation

AGIC continuously watches the Kubernetes state and attempts to keep Application Gateway configuration synchronized with that desired state.

For example:

```text
Kubernetes Ingress

/api
  |
  v
backend-service:8080
```

AGIC translates this into Application Gateway configuration:

```text
Application Gateway
       |
       v
Routing Rule
       |
       +--> /api/*
              |
              v
         Backend Pool
              |
              v
       Backend HTTP Settings
              |
              v
           Port 8080
```

This removes the need to manually update Application Gateway every time Kubernetes application routing changes.

---

# 15. AGIC Control Plane vs Application Data Plane

This distinction is important.

### Control Plane

AGIC manages Application Gateway configuration:

```text
Kubernetes
    |
    v
  AGIC
    |
    v
Application Gateway Configuration
```

### Data Plane

Application Gateway handles actual client traffic:

```text
Client
   |
   v
Application Gateway
   |
   v
AKS Workload
```

Therefore, AGIC is **not sitting in the packet path** between the client and the application.

---

# 16. AGIC Managed Identity and RBAC

AGIC requires an Azure identity to communicate with Azure resources.

The project used a managed identity for AGIC.

The authentication and authorization flow is:

```text
AGIC Pod
   |
   v
Managed Identity
   |
   v
Microsoft Entra ID
   |
   v
Azure RBAC
   |
   v
Azure Resources
```

The project validation found Azure RBAC roles including:

* Network Contributor
* Managed Identity Operator
* Contributor
* Reader

The exact scope of each role assignment is important.

A better interview explanation is:

> AGIC used a managed identity, and Azure RBAC permissions were assigned at the required resource scopes so the controller could reconcile Application Gateway and related networking resources.

---

# 17. AGIC Troubleshooting and Validation

The AGIC integration required validation of:

1. Application Gateway
2. WAF
3. HTTPS listener
4. Backend pool
5. Backend HTTP settings
6. Health probes
7. Kubernetes Ingress
8. AGIC
9. AGIC managed identity
10. Azure RBAC

### AGIC Pod Validation

The AGIC deployment was validated using:

```bash
kubectl get pods -n kube-system | Select-String "ingress-appgw"
```

The AGIC Pod was confirmed to be:

```text
1/1 Running
```

### AGIC Logs

The AGIC logs were checked using:

```bash
kubectl logs -n kube-system deployment/ingress-appgw-deployment --tail=100
```

The logs showed the generated Application Gateway configuration being applied successfully.

---

# 18. End-to-End API Validation

One of the strongest validation points was a real API request through Application Gateway.

The request was:

```text
https://enterpriseapitask.online/api/tasks
```

Application Gateway access logs showed:

```text
host_s          = enterpriseapitask.online
requestUri_s    = /api/tasks
sslEnabled_s    = on
sslProtocol_s   = TLSv1.3
serverRouted_s  = 10.10.2.30:8080
httpStatus_d    = 200
```

Therefore, the actual request flow was:

```text
Browser
   |
   | HTTPS :443
   v
enterpriseapitask.online
   |
   v
Application Gateway
   |
   v
WAF
   |
   v
/api/tasks
   |
   v
Backend Pool
   |
   v
10.10.2.30:8080
   |
   v
HTTP 200
```

This provides real evidence that the end-to-end ingress path was successfully working.

---

# 19. TLS/SSL Certificate with Certbot

The project used Certbot/Let's Encrypt to obtain the TLS certificate for:

```text
enterpriseapitask.online
```

The certificate workflow was:

```text
Let's Encrypt
      |
      v
   Certbot
      |
      v
TLS Certificate
      |
      v
PFX Certificate
      |
      v
Application Gateway
      |
      v
HTTPS Listener :443
```

Certbot can obtain the certificate using:

```bash
sudo certbot certonly --standalone \
  -d enterpriseapitask.online
```

Certificates are stored under:

```text
/etc/letsencrypt/live/enterpriseapitask.online/
```

Important certificate files include:

```text
fullchain.pem
privkey.pem
cert.pem
chain.pem
```

A PFX can be created for direct Application Gateway certificate import:

```bash
sudo openssl pkcs12 -export \
  -out enterpriseapitask.online.pfx \
  -inkey /etc/letsencrypt/live/enterpriseapitask.online/privkey.pem \
  -in /etc/letsencrypt/live/enterpriseapitask.online/cert.pem \
  -certfile /etc/letsencrypt/live/enterpriseapitask.online/chain.pem
```

The resulting PFX contains the certificate and private key.

---

# 20. TLS Termination

The Application Gateway terminates the client TLS connection.

```text
Client
   |
   | HTTPS :443
   v
Application Gateway
   |
   | TLS Termination
   |
   | HTTP :8080
   v
Backend
```

This means HTTPS is used between the client and Application Gateway, while the configured backend connection uses HTTP on port `8080`.

---

# 21. Certificate Renewal

Let's Encrypt certificates are short-lived and require renewal.

A renewal test can be performed using:

```bash
sudo certbot renew --dry-run
```

After certificate renewal, the certificate used by Application Gateway must also be updated if the certificate was manually imported as a PFX.

> Certbot renewal alone does not automatically update an already-imported Application Gateway certificate.

---

# 22. Application Gateway Monitoring

Application Gateway diagnostics were configured to send telemetry to the Log Analytics Workspace:

```text
Diagnostic Setting:
diag-appgw-dev

Log Analytics Workspace:
law-enterprise-dev
```

Enabled log categories included:

* `ApplicationGatewayAccessLog`
* `ApplicationGatewayFirewallLog`
* `ApplicationGatewayPerformanceLog`

Metrics were also enabled through:

```text
AllMetrics
```

Important Application Gateway metrics include:

* `TotalRequests`
* `FailedRequests`
* `HealthyHostCount`
* `UnhealthyHostCount`
* `CurrentConnections`
* `NewConnectionsPerSecond`
* `BackendResponseStatus`
* `ApplicationGatewayTotalTime`
* `BackendConnectTime`
* `BackendFirstByteResponseTime`
* `BackendLastByteResponseTime`
* WAF-related request and rule metrics

These metrics provide visibility into application traffic, backend health, performance, and WAF activity.

---

# 23. Complete Architecture

The complete architecture can be summarized as:

```text
                              INTERNET
                                  |
                                  | HTTPS :443
                                  v
                              Public IP
                                  |
                                  v
                    +---------------------------+
                    |   Application Gateway     |
                    |          WAF v2           |
                    |                           |
                    | HTTPS Listener            |
                    | Path-Based Routing        |
                    | Backend Pools             |
                    | Health Probes              |
                    +-------------+-------------+
                                  |
                                  v
                         AGIC-managed routing
                                  |
                                  v
                         Kubernetes Ingress
                           /             \
                          /               \
                         v                 v
                    Frontend           Backend
                                           |
                                           v
                                      AKS Workload
                                           |
                                           v
                                      Port 8080
```

The AGIC control-plane relationship is:

```text
                    AKS
                     |
                     v
                  AGIC Pod
                     |
                     v
              Managed Identity
                     |
                     v
               Azure RBAC
                     |
                     v
          Application Gateway
```

---

# 24. Complete Request Flow

The complete request flow validated in the project was:

```text
Client
  |
  | HTTPS :443
  v
Public IP
  |
  v
Application Gateway
  |
  v
WAF v2
  |
  v
HTTPS Listener
  |
  v
Path-Based Routing
  |
  +-----------------------+
  |                       |
  | /                     | /api/*
  v                       v
Frontend              Backend Pool
                          |
                          v
                    10.10.2.30:8080
                          |
                          v
                     AKS Workload
```

---

# 25. Key Takeaways

The project demonstrates the integration of:

* **Application Gateway** as the public Layer-7 ingress point
* **WAF v2** for application-layer protection
* **HTTPS/TLS** for secure client connectivity
* **Path-based routing** for frontend and backend traffic
* **AGIC** for Kubernetes-driven Application Gateway configuration
* **Managed Identity and Azure RBAC** for secure Azure access
* **AKS** for containerized workloads
* **Health probes** for backend availability
* **Azure Monitor and diagnostics** for observability
* **Certbot/Let's Encrypt** for TLS certificate management

The most important architectural distinction is:

```text
AGIC
  = Control / Configuration Plane

Application Gateway
  = Ingress / Data Plane
```

AGIC translates Kubernetes ingress configuration into Application Gateway configuration, while Application Gateway handles the actual incoming client traffic.

---

# 26. Interview Explanation

A concise explanation of the implementation is:

> We used Azure Application Gateway with WAF v2 as the public ingress layer for our AKS-based application. HTTPS traffic on port 443 reaches the Application Gateway, where TLS is terminated and WAF inspection is performed. Path-based routing sends `/` traffic to the frontend and `/api/*` traffic to the backend. AGIC runs inside AKS and continuously reconciles Kubernetes Ingress configuration with Application Gateway listeners, backend pools, HTTP settings and routing rules. AGIC uses a managed identity with Azure RBAC permissions to communicate with Azure resources. We validated the implementation using Application Gateway access logs, which showed TLS 1.3 and a successful `/api/tasks` request routed to `10.10.2.30:8080` with HTTP 200.
