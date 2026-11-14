# AKS deployment order

1. Replace placeholders in serviceaccount.yaml, backend-configmap.yaml and ingress.yaml.
2. Ensure AKS can pull from ACR.
3. Ensure NGINX ingress controller is installed if you are using NGINX behind Application Gateway.
4. Apply namespace/service account/config.
5. Deploy the backend initially with Database__ApplyMigrations=true and replicas=1 for the first schema deployment, or run the EF migration from a controlled CI/CD step.
6. Set Database__ApplyMigrations=false and scale backend to 2+ replicas.
7. Deploy frontend and ingress.
8. Put Application Gateway/WAF in front of the ingress endpoint.

The Azure SQL connection is passwordless in this manifest. The application must be configured for Microsoft Entra/Workload Identity before the AKS deployment is considered complete.
