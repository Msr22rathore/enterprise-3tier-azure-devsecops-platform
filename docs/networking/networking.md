# 3. Networking

## 3.1 Overview

The networking layer provides the foundation for the three-tier
application platform.

The Azure network is designed to separate the Application Gateway,
AKS workloads and private Azure services into dedicated subnets.

The networking layer consists of:

- Azure Virtual Network
- Application Gateway subnet
- AKS subnet
- Private Endpoint subnet
- Network Security Groups
- NSG-to-subnet associations
- NAT Gateway
- NAT Gateway Public IP
- NAT Gateway-to-AKS-subnet association
- Route Tables / User Defined Routes where required
- Private connectivity to Azure services

---

## 3.2 Virtual Network

The platform uses an Azure Virtual Network as the primary private
network boundary.

```text
Azure VNet
│
├── Application Gateway Subnet
│
├── AKS Subnet
│
└── Private Endpoint Subnet

The Terraform networking module uses a reusable configuration:

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space


  tags = var.tags
}

The VNet address space is supplied through Terraform variables rather
than being hardcoded inside the module.

3.3 Dynamic Subnet Creation

The networking module creates subnets dynamically using for_each.

resource "azurerm_subnet" "this" {
  for_each = var.subnets


  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

This allows the same Terraform module to create different subnet
layouts for different environments.

Conceptually:

var.subnets
    |
    +-- snet-appgw
    |
    +-- snet-aks
    |
    +-- snet-private-endpoints

Each subnet receives its address prefix from the corresponding
Terraform variable.

3.4 Application Gateway Subnet

The Application Gateway is deployed into a dedicated subnet.

snet-appgw
    |
    └── Application Gateway
             |
             └── WAF v2

The Application Gateway subnet separates the public application
ingress layer from the Kubernetes workload subnet.

Incoming application traffic reaches Application Gateway first.

Internet
   |
   v
Application Gateway
   |
   v
AKS
3.5 AKS Subnet

The AKS nodes are deployed into a dedicated subnet.

snet-aks
   |
   +-- AKS nodes
   |
   +-- Kubernetes workloads
   |
   +-- Frontend
   |
   +-- Backend API

The AKS subnet is also the subnet associated with the NAT Gateway.

3.6 NAT Gateway

The NAT Gateway provides controlled outbound internet connectivity
for the AKS subnet.

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

The NAT Gateway is not the public entry point for the application.

Inbound application traffic follows:

Internet
   |
   v
Application Gateway
   |
   v
AKS

Outbound workload traffic follows:

AKS
   |
   v
NAT Gateway
   |
   v
Internet

This provides a clear separation between inbound application
traffic and outbound workload traffic.

3.7 NAT Gateway Public IP

The NAT Gateway uses a Standard Static Public IP.

Conceptually:

NAT Gateway
     |
     v
Static Public IP
     |
     v
Internet

Using a static public IP provides a predictable source IP for
outbound connections initiated from the associated subnet.

3.8 NAT Gateway Subnet Association

The NAT Gateway is associated with the AKS subnet.

Terraform uses:

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = toset(var.nat_gateway_subnet_names)


  subnet_id      = azurerm_subnet.this[each.value].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

The environment passes only the AKS subnet:

nat_gateway_subnet_names = ["snet-aks"]

Therefore:

snet-appgw                  → NAT Gateway: No
snet-aks                    → NAT Gateway: Yes
snet-private-endpoints      → NAT Gateway: No

This keeps the NAT Gateway association explicit and configurable.

3.9 Network Security Groups

Network Security Groups provide network-level traffic filtering.

The Terraform module creates NSGs dynamically:

resource "azurerm_network_security_group" "this" {
  for_each = var.nsgs


  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name


  tags = var.tags
}

The NSGs are then associated with their respective subnets.

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.nsgs


  subnet_id = azurerm_subnet.this[
    each.value.subnet_name
  ].id


  network_security_group_id = azurerm_network_security_group.this[
    each.key
  ].id
}

This makes the network security configuration data-driven.

3.10 Network Security Model

The network security model can be represented as:

                    INTERNET
                       |
                       | HTTPS
                       v
              Application Gateway
                       |
                       v
                 AKS Subnet
                       |
             +---------+---------+
             |                   |
         Frontend             Backend
                                 |
                                 v
                            Azure Services

NSGs provide subnet-level controls around the network boundaries.

Application-level HTTP/HTTPS protection is provided separately
through Application Gateway and WAF.

3.11 Private Endpoint Subnet

Private Endpoints are placed into a dedicated subnet.

Private Endpoint Subnet
        |
        +-- SQL Private Endpoint
        |
        +-- Key Vault Private Endpoint
        |
        +-- Storage Private Endpoint

The purpose is to provide private connectivity between the
application platform and supported Azure services.

Conceptually:

AKS / Application
       |
       v
Private Endpoint
       |
       v
Azure Service
3.12 Application Traffic Flow

The complete inbound traffic flow is:

                         INTERNET
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
                    Routing Rules
                            |
                            v
                          AKS
                     +------+------+
                     |             |
                 Frontend       Backend
                                   |
                                   v
                               Azure SQL

Application Gateway is therefore the primary public ingress
component.

3.13 Outbound Traffic Flow

Outbound traffic from AKS follows:

             AKS Workload
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

The NAT Gateway provides outbound source network address
translation.

It does not provide inbound port forwarding to AKS.

3.14 Private Service Traffic

For Azure services exposed through Private Endpoints:

Application
     |
     v
Private Network
     |
     v
Private Endpoint
     |
     v
Azure Service

This architecture reduces the need for public connectivity between
the application and internal Azure platform services.

3.15 Network Components and Responsibilities
Component	Responsibility
Virtual Network	Private network boundary
Application Gateway Subnet	Hosts Application Gateway
AKS Subnet	Hosts AKS node infrastructure
Private Endpoint Subnet	Hosts Private Endpoints
NSG	Network traffic filtering
NAT Gateway	Predictable outbound connectivity
NAT Public IP	Stable outbound source IP
Application Gateway	Inbound application traffic
WAF	HTTP/HTTPS application-layer protection
Private Endpoint	Private access to supported Azure services
Route Table / UDR	Custom traffic routing where configured
3.16 Network Security Boundaries

The architecture establishes multiple security boundaries:

                 INTERNET
                    |
                    v
          Application Gateway
                    |
                  WAF
                    |
                    v
               AKS Subnet
                    |
           +--------+--------+
           |                 |
       Application       Backend
           |                 |
           +--------+--------+
                    |
                    v
             Private Services

The Application Gateway/WAF boundary protects the public
application entry point.

NSGs provide network-level controls.

Private Endpoints provide private service connectivity.

NAT Gateway controls outbound internet connectivity from the
associated subnet.

3.17 Terraform Networking Architecture

The networking module is designed to be reusable.

modules/network
|
├── main.tf
├── variables.tf
└── outputs.tf

The module receives configuration through variables such as:

vnet_name
vnet_address_space
subnets
nsgs
nat_gateway_subnet_names

The environment supplies the environment-specific values.

environments/dev
       |
       v
modules/network
       |
       +-- VNet
       +-- Subnets
       +-- NSGs
       +-- NSG associations
       +-- NAT Gateway
       +-- NAT Public IP
       +-- NAT subnet association

This approach avoids hardcoding environment-specific values inside
the reusable network module.

3.18 Network Design Summary

The network architecture separates responsibilities across dedicated
subnets and traffic paths.

Inbound
Internet
   ↓
Application Gateway
   ↓
WAF
   ↓
AKS
Outbound
AKS
   ↓
NAT Gateway
   ↓
Static Public IP
   ↓
Internet
Private Azure services
Application
   ↓
Private Endpoint
   ↓
Azure SQL / Key Vault / Storage
Network security
Subnets
   ↓
NSGs
   ↓
Traffic filtering

This design provides a structured network foundation for the
three-tier DevSecOps platform.



### What Part 3 now establishes


Your GitHub documentation will clearly show that **NAT Gateway belongs to the AKS subnet**, while **Application Gateway belongs to the App Gateway subnet**:


```text
VNet
│
├── snet-appgw
│     └── Application Gateway + WAF
│
├── snet-aks
│     ├── AKS
│     └── NAT Gateway association
│
└── snet-private-endpoints
      └── Private Endpoints





      Private Endpoint + Private DNS — how it works

The architecture is:

                    Azure VNet
                       │
                       │
              ┌────────┴────────┐
              │ Private Endpoint│
              │    Subnet       │
              └────────┬────────┘
                       │
                       ▼
                Private Endpoint
                       │
                       ▼
                Azure PaaS Service
              ┌────────┼─────────┐
              │        │         │
            SQL     Key Vault   Storage

But Private Endpoint alone isn't the whole story.

We also need DNS so that the normal Azure service hostname resolves to the private IP.

For example, conceptually:

Application
     │
     │ sql-enterprises-dev.database.windows.net
     ▼
Private DNS
     │
     │ resolves to private IP
     ▼
Private Endpoint
     │
     ▼
Azure SQL

Without the correct private DNS configuration, an application could know the service hostname but resolve it incorrectly or fail to resolve it through the intended private path.

The complete Private Endpoint + DNS architecture
                         Azure VNet
                            │
                            │
              ┌─────────────┴──────────────┐
              │                            │
              ▼                            ▼
      Private DNS Zone              Private Endpoint
              │                            │
              │ VNet Link                  │
              │                            │
              └─────────────┬──────────────┘
                            │
                            ▼
                    Private IP Address
                            │
                            ▼
                       Azure PaaS

There are usually three important pieces:

1. Private Endpoint

Creates a private network interface/private IP for the Azure service.

Private Endpoint
       │
       ▼
Private IP
2. Private DNS Zone

Contains the DNS records needed to resolve the Azure service hostname to the private endpoint.

3. VNet Link

Links the Private DNS Zone to your VNet so resources inside the VNet can resolve those names.

Example: Storage

Your project had:

pep-storage-dev

for the Storage account.

The conceptual flow is:

AKS/Application
      │
      │ Storage hostname
      ▼
Private DNS Zone
      │
      │ DNS resolution
      ▼
Private Endpoint
      │
      │ Private IP
      ▼
Storage Account

Instead of:

Application
    │
    ▼
Public Storage endpoint
    │
    ▼
Internet

we use:

Application
    │
    ▼
Private DNS
    │
    ▼
Private Endpoint
    │
    ▼
Storage
Why DNS is necessary

This is a very important interview point.

A Private Endpoint gives you a private IP, but applications normally connect using a hostname.

For example:

storageaccount.blob.core.windows.net

The application shouldn't have to manually use:

10.x.x.x

Instead:

storageaccount.blob.core.windows.net
             │
             ▼
        DNS resolution
             │
             ▼
        Private IP
             │
             ▼
     Private Endpoint

That's why Private Endpoint + Private DNS are normally considered together.

What we'll document in your project

The security architecture should therefore be:

                 AKS
                  │
                  ▼
          Private DNS Resolution
                  │
                  ▼
           Private DNS Zone
                  │
             VNet Link
                  │
                  ▼
          Private Endpoint
                  │
                  ▼
          Azure PaaS Service

And your public application path remains completely separate:

Internet
   │
   ▼
Application Gateway
   │
   ▼
WAF
   │
   ▼
AKS

So your final architecture has three different traffic patterns:

1. INBOUND APPLICATION


Internet
   ↓
Application Gateway
   ↓
WAF
   ↓
AKS




2. OUTBOUND INTERNET


AKS
   ↓
NAT Gateway
   ↓
Static Public IP
   ↓
Internet




3. PRIVATE AZURE SERVICES


AKS/Application
   ↓
Private DNS
   ↓
Private Endpoint
   ↓
SQL / Key Vault / Storage