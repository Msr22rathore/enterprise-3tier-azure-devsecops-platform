🧠 First understand what we did

Our basic model was:

Terraform Configuration
        │
        ▼
Terraform Modules
        │
        ▼
Azure Resources

Instead of manually creating:

VNet
AKS
Application Gateway
SQL
Key Vault
Storage
...

from the Azure Portal, we defined them as Terraform resources.

5.1 Terraform module architecture

Our project was organized into reusable modules.

Conceptually:

infra/
└── terraform/
    │
    ├── modules/
    │   ├── network/
    │   ├── aks/
    │   ├── application-gateway/
    │   ├── rbac/
    │   ├── sql/
    │   ├── storage/
    │   ├── key-vault/
    │   └── diagnostics/
    │
    └── environments/
        └── dev/

The important concept is:

Environment
     │
     ▼
Module
     │
     ▼
Azure Resource

For example:

dev/main.tf
     │
     ▼
network module
     │
     ├── VNet
     ├── Subnets
     ├── NSGs
     └── NAT Gateway
5.2 Why we used modules

Instead of putting everything into one huge main.tf, we separated infrastructure according to responsibility.

For example:

network module
    ↓
Networking


aks module
    ↓
Kubernetes


application-gateway module
    ↓
Ingress


rbac module
    ↓
Permissions


diagnostics module
    ↓
Monitoring

This provides:

Reusability
Separation of concerns
Easier maintenance
Environment consistency
Smaller Terraform configurations
Easier troubleshooting
5.3 Environment-specific configuration

The development environment consumes the reusable modules.

Conceptually:

module "network" {
  source = "../../modules/network"


  ...
}

The module itself doesn't need to know whether it is being used for:

dev
test
staging
prod

The environment supplies the appropriate values.

5.4 Terraform Variables

Variables allow us to avoid hardcoding environment-specific configuration inside modules.

Your networking module, for example, uses:

variable "vnet_name" {
  type = string
}


variable "vnet_address_space" {
  type = list(string)
}


variable "subnets" {
  ...
}


variable "nsgs" {
  ...
}

The subnet structure is passed into the module and created dynamically.

For example:

subnets = {
  snet-appgw = {
    address_prefixes = ["..."]
  }


  snet-aks = {
    address_prefixes = ["..."]
  }


  snet-private-endpoints = {
    address_prefixes = ["..."]
  }
}

The module then uses:

for_each = var.subnets

to create the subnets.

5.5 Dynamic Terraform resources

One of the useful patterns we used was:

resource "azurerm_subnet" "this" {
  for_each = var.subnets


  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

Instead of creating:

resource "azurerm_subnet" "aks" {}
resource "azurerm_subnet" "appgw" {}
resource "azurerm_subnet" "private" {}

we use a single reusable resource with for_each.

This is an important Terraform pattern.

5.6 Dynamic NAT Gateway association

We also designed the NAT Gateway association dynamically.

The module accepts:

variable "nat_gateway_subnet_names" {
  type    = set(string)
  default = []
}

The dev environment can then specify:

nat_gateway_subnet_names = ["snet-aks"]

The module associates the NAT Gateway with that subnet:

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = toset(var.nat_gateway_subnet_names)


  subnet_id      = azurerm_subnet.this[each.value].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

This keeps the module reusable.

5.7 Terraform Outputs

Modules expose important information through outputs.

For example, your AKS module has outputs such as:

output "id" {
  value = azurerm_kubernetes_cluster.this.id
}


output "name" {
  value = azurerm_kubernetes_cluster.this.name
}


output "principal_id" {
  value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}


output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}


output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

These outputs allow other parts of the Terraform configuration to consume information from the module.

For example:

AKS module
    │
    ├── AKS ID
    ├── AKS identity
    ├── Kubelet identity
    └── OIDC issuer
            │
            ▼
        RBAC / Other modules
5.8 Dependency management

Terraform automatically builds a dependency graph from references.

For example:

VNet
 │
 ▼
Subnet
 │
 ▼
AKS

and:

AKS identity
      │
      ▼
RBAC role assignment

and:

Log Analytics
      │
      ▼
Diagnostic Settings

Terraform therefore knows the required creation order when resources reference one another.

5.9 Terraform Plan

Before modifying Azure infrastructure, we use:

terraform plan

This allows us to inspect what Terraform intends to change.

For example, during the AGIC identity correction, Terraform showed:

-/+ destroy and then create replacement

because the principal_id changed.

The important part was:

principal_id = old-id -> new-id
             # forces replacement

This is a real example of Terraform detecting infrastructure drift/change and determining that an RBAC assignment must be recreated.

5.10 Terraform Apply

After reviewing the plan:

terraform apply

creates or updates the Azure resources.

For saved plans:

terraform apply "dev.tfplan"

applies exactly the previously generated plan.

This is safer than blindly applying changes without reviewing them.

5.11 Terraform Validate

We use:

terraform validate

to verify that the Terraform configuration is syntactically and structurally valid.

Typical workflow:

terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review
      ↓
terraform apply
5.12 Terraform Format

We use:

terraform fmt -recursive

to format Terraform files consistently.

This is especially useful when multiple modules are maintained in the same repository.

5.13 Terraform State

Terraform maintains state to track the relationship between:

Terraform configuration
        ↕
Terraform state
        ↕
Azure infrastructure

During our project, Terraform refreshed existing resources before generating plans.

For example:

Refreshing state...

followed by:

Terraform used the selected providers to generate the following
execution plan.

This is how Terraform compares the desired configuration with the known infrastructure state.

5.14 Terraform and Managed Identities

A particularly important part of this project was identity handling.

We initially encountered a situation where role assignments referenced an older identity:

old principal_id
       ↓
new principal_id

Terraform detected:

# forces replacement

The RBAC assignments therefore had to be recreated for the current identity.

This demonstrated an important real-world Terraform concept:

Azure managed identity principal IDs are not values that should be treated as permanent hardcoded identifiers.

The configuration should reference the identity dynamically whenever possible.

5.15 Terraform and AKS

The AKS module configures:

oidc_issuer_enabled       = true
workload_identity_enabled = true

and:

identity {
  type = "SystemAssigned"
}

The module exposes the resulting identity information through outputs.

This allows other Terraform modules to consume those identities without hardcoding their IDs.

5.16 Terraform and Application Gateway

Application Gateway infrastructure is also managed through Terraform.

The architecture connects:

Terraform
   │
   ▼
Application Gateway
   │
   ├── Public IP
   ├── Frontend
   ├── HTTPS listener
   ├── Backend pools
   ├── HTTP settings
   ├── Routing rules
   ├── Health probes
   └── WAF

AGIC then dynamically manages Kubernetes-driven Application Gateway configuration.

This gives us two layers:

Terraform
   │
   ▼
Base Application Gateway infrastructure


AGIC
   │
   ▼
Kubernetes-driven ingress configuration
5.17 Terraform and Monitoring

Monitoring resources are also managed through Terraform.

The architecture includes:

Terraform
   │
   ├── Log Analytics Workspace
   ├── Diagnostic Settings
   ├── Metric Alerts
   └── Action Groups

For example:

Application Gateway
       │
       ▼
Diagnostic Setting
       │
       ▼
Log Analytics

This allows monitoring configuration to be version-controlled alongside the infrastructure.

5.18 Infrastructure Lifecycle

The complete infrastructure lifecycle is:

Developer changes Terraform
          │
          ▼
terraform fmt
          │
          ▼
terraform validate
          │
          ▼
terraform plan
          │
          ▼
Review planned changes
          │
          ▼
terraform apply
          │
          ▼
Azure infrastructure
          │
          ▼
Validation / Testing
5.19 Terraform Design Principles

The Terraform implementation follows these principles:

Modular design

Infrastructure is divided into reusable modules.

Parameterization

Environment-specific values are passed through variables.

Dynamic resources

Terraform for_each is used for reusable resource creation.

Outputs

Important resource IDs and identity information are exposed through module outputs.

Plan before apply

Infrastructure changes are reviewed before being applied.

Least hardcoding

Resource IDs and identity information are referenced dynamically whenever possible.

Environment separation

Development configuration is separated from reusable infrastructure modules.

5.20 Terraform Summary

Terraform provides the Infrastructure as Code foundation for the
project.

The major infrastructure components are provisioned through
reusable modules and environment-specific configuration.

The resulting workflow is:

Terraform Code
      |
      v
Reusable Modules
      |
      v
Environment Configuration
      |
      v
Terraform Plan
      |
      v
Terraform Apply
      |
      v
Azure Infrastructure

This approach provides repeatable, reviewable and version-controlled
infrastructure deployment