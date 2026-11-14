# 4. Security & RBAC

## 4.1 Security Overview

Security is implemented across multiple layers of the Azure
three-tier DevSecOps platform.

The security architecture includes:

- Network Security Groups
- Application Gateway
- Web Application Firewall
- HTTPS/TLS
- Azure RBAC
- Managed Identities
- Workload Identity / OIDC
- Azure Key Vault
- Private Endpoints
- Controlled outbound connectivity using NAT Gateway

The security model follows defense-in-depth and least-privilege
principles.

---

## 4.2 Network Security

Network-level security is implemented using Network Security Groups
associated with application subnets.

The Terraform networking module creates NSGs dynamically:

```hcl
resource "azurerm_network_security_group" "this" {
  for_each = var.nsgs

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

The NSGs are associated with their corresponding subnets:

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.nsgs


  subnet_id = azurerm_subnet.this[
    each.value.subnet_name
  ].id


  network_security_group_id = azurerm_network_security_group.this[
    each.key
  ].id
}

This provides subnet-level network traffic control.

4.3 Application Gateway and WAF

Azure Application Gateway provides the public ingress point for
the application.

The traffic flow is:

Internet
   |
   v
Application Gateway
   |
   v
WAF
   |
   v
AKS

The Application Gateway uses WAF v2 to inspect incoming HTTP/HTTPS
requests.

The WAF policy was configured in Prevention mode.

This provides protection against common web application attacks
before traffic reaches the Kubernetes workloads.

4.4 HTTPS and TLS

HTTPS is enabled on the Application Gateway.

The application traffic flow is:

Client
   |
   | HTTPS :443
   v
Application Gateway
   |
   v
AKS

The project uses a custom application domain and TLS encryption
for the public application endpoint.

Application Gateway diagnostic telemetry confirmed TLS-enabled
requests and TLS 1.3 traffic during validation.

4.5 Managed Identity

Managed identities are used to allow Azure resources and workloads
to authenticate to Azure services without storing long-lived
credentials in application configuration.

The identity model is:

Workload / Controller
        |
        v
Managed Identity
        |
        v
Azure RBAC
        |
        v
Azure Resource

This reduces the need to store service principal secrets inside
the application environment.

4.6 AGIC Identity and RBAC

Application Gateway Ingress Controller requires Azure permissions
to reconcile the Application Gateway configuration based on
Kubernetes Ingress resources.

The AGIC identity was assigned appropriate permissions for:

Application Gateway
Resource Group
Managed Identity
Required Azure networking resources

The permissions were verified using Azure CLI rather than relying
only on Terraform configuration.

Example:

az role assignment list `
  --assignee <AGIC-IDENTITY-OBJECT-ID> `
  --all `
  --query "[].{role:roleDefinitionName,scope:scope}" `
  -o table

This allowed the deployed identity and its actual Azure permissions
to be verified.

4.7 RBAC Permissions

The AGIC integration used role assignments at appropriate scopes.

The project included permissions such as:

Application Gateway
    |
    +-- Contributor


Resource Group
    |
    +-- Reader


Managed Identity
    |
    +-- Managed Identity Operator


Required AKS managed networking resources
    |
    +-- Network Contributor

The exact scope of each permission is important because Azure RBAC
is scope-aware.

4.8 Workload Identity and OIDC

AKS was configured with:

oidc_issuer_enabled       = true
workload_identity_enabled = true

This enables Kubernetes workloads to authenticate to Azure using
federated identity instead of storing long-lived Azure credentials.

The conceptual flow is:

Kubernetes Workload
        |
        v
Kubernetes Service Account
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
4.9 Azure Key Vault

Azure Key Vault is used as the centralized secret and certificate
management service.

The intended access model is:

Application
     |
     v
Managed Identity
     |
     v
Azure RBAC
     |
     v
Key Vault

Private connectivity is used for supported internal service access.

This avoids embedding sensitive credentials directly into application
source code.

4.10 Private Endpoints

Private Endpoints provide private connectivity to supported Azure
services.

The architecture is:

Application / AKS
       |
       v
Private Endpoint
       |
       v
Azure Service

The project uses private connectivity for platform services such
as Azure SQL, Key Vault and Storage where configured.

4.11 NAT Gateway Security Role

The NAT Gateway provides controlled outbound connectivity for the
AKS subnet.

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

The NAT Gateway is used for outbound traffic.

It is not the public inbound application endpoint.

Inbound traffic is handled by:

Internet
   |
   v
Application Gateway
   |
   v
WAF
   |
   v
AKS
4.12 Defense in Depth

The resulting security architecture provides multiple layers:

                INTERNET
                   |
                   v
          Application Gateway
                   |
                   v
                  WAF
                   |
                   v
             Network Controls
                   |
                   v
                  AKS
                   |
          +--------+--------+
          |                 |
      Managed Identity     RBAC
          |                 |
          +--------+--------+
                   |
                   v
             Azure Services
                   |
             Private Endpoints

Each layer addresses a different security concern.

4.13 Security Principles
Least Privilege

Azure identities receive only the permissions required for their
responsibilities.

Identity-Based Authentication

Managed identities and workload identity are preferred over
long-lived credentials.

Network Isolation

Dedicated subnets and NSGs separate different infrastructure
components.

Private Connectivity

Private Endpoints provide private access to supported Azure services.

Application Protection

Application Gateway WAF protects the public application ingress.

Encrypted Transport

HTTPS/TLS is used for public application traffic.

Controlled Outbound Connectivity

NAT Gateway provides predictable outbound connectivity for the
AKS subnet.

4.14 Security Validation

Security configuration was validated using:

Terraform plan and state
Azure CLI
Azure Portal
Kubernetes commands
Application Gateway logs
WAF telemetry
Azure RBAC role assignment inspection

This allowed the implemented security configuration to be verified
against the intended architecture.


