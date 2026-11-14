# Enterprise Task Platform

A realistic but intentionally small 3-tier application for the Azure DevSecOps project.

## Stack
Angular + TypeScript | ASP.NET Core 8 Web API | Entity Framework Core | Azure SQL | Blob Storage | Docker | ACR | AKS | Application Gateway/WAF | Key Vault | Workload Identity | Azure DevOps | Azure Monitor

## Architecture
Angular -> Application Gateway/WAF -> AKS Ingress -> ASP.NET Core API -> EF Core -> Azure SQL
                                                API -> Azure Blob Storage

## Repository
backend/      ASP.NET Core API
frontend/     Angular SPA
database/     database/migration notes
docker-compose.yml local SQL Server + API
k8s/          AKS manifests
.azuredevops/ Azure DevOps pipeline starter

## Local development
Prerequisites: .NET 8 SDK, Node.js 20+, Docker Desktop.

Terminal 1:
  docker compose up -d sqlserver

Terminal 2:
  cd backend/EnterpriseTask.Api
  dotnet restore
  dotnet run

Terminal 3:
  cd frontend/enterprise-task-ui
  npm install
  npm start

Open http://localhost:4200
Swagger: http://localhost:8080/swagger
Health: http://localhost:8080/health/live
Readiness: http://localhost:8080/health/ready

The Development environment automatically applies EF Core migrations. The first run therefore creates the schema. You should create a user first:
POST /api/users
{"name":"Sunny","email":"sunny@example.com"}
Then create a task using the returned user id.

## Local all-container API
  docker compose up --build
The Angular UI is still run with npm start for the simplest local development loop.

## Azure deployment target
The infrastructure already created in the Azure project is intended to be reused: rg-app-dev, vnet, AKS, ACR, Azure SQL, Storage, private endpoints/DNS, Key Vault, Application Gateway/WAF, Log Analytics and alerts.

The Kubernetes connection string intentionally contains no password. Before AKS deployment, configure Microsoft Entra authentication for Azure SQL and Workload Identity for the API service account. Do not commit SQL passwords or Key Vault secrets.

## DevSecOps increments
1. Local app
2. Docker
3. ACR
4. Manual AKS deployment
5. Workload Identity + Azure SQL/Blob private access
6. Application Gateway/WAF + ingress
7. Azure DevOps CI
8. SonarQube + dependency/security scanning
9. Trivy image scan
10. ACR push + CD to AKS
11. Smoke tests
12. Azure Monitor/Log Analytics
13. GitOps/Argo CD as an optional final increment

## Blob attachments
The API includes `POST /api/files/upload`. In Azure/AKS set `AzureStorage:AccountName` to the existing storage account name and grant the workload identity the appropriate Storage Blob Data Contributor role. The Blob client uses `DefaultAzureCredential`, so no storage account key is required.
