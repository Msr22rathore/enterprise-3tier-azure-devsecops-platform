# Azure SQL identity setup

The API supports passwordless Azure SQL authentication when `AzureSql__UseManagedIdentity=true`.

The `AzureSqlAccessTokenInterceptor` obtains an Entra access token using `DefaultAzureCredential` and attaches it to the SqlClient connection.

For AKS:
1. Enable Microsoft Entra Workload Identity/OIDC (your AKS already has OIDC).
2. Create/use a user-assigned identity for the API.
3. Annotate the Kubernetes service account with its client ID and tenant ID.
4. Federate the service account subject with the user-assigned identity.
5. Grant the identity an appropriate Azure SQL data-plane/database principal and permissions.
6. Keep the connection string passwordless and leave `AzureSql__UseManagedIdentity=true`.

For local Azure SQL testing, `az login` can be used because `DefaultAzureCredential` includes Azure CLI credentials. Local Docker SQL Server continues to use SQL authentication with the flag set to false.
