
# 10. Monitoring, Logging, Metrics & Alerts


## Overview


The project uses Azure-native monitoring services to provide
centralized logging, metrics and alerting.


The monitoring architecture is:


```text
Azure Resources
      |
      v
Azure Monitor
      |
 +----+----+
 |    |    |
Logs Metrics Alerts
 |           |
 v           v
Log        Action Group
Analytics      |
 |             v
KQL           Email
Log Analytics

The centralized Log Analytics workspace is:

law-enterprise-dev

Configuration validated during the project:

Location: Central India
SKU: PerGB2018
Retention: 30 days
Application Gateway Diagnostics

Application Gateway uses the diagnostic setting:

diag-appgw-dev

Logs enabled:

ApplicationGatewayAccessLog
ApplicationGatewayFirewallLog
ApplicationGatewayPerformanceLog

Metrics:

AllMetrics

The destination is:

law-enterprise-dev
Application Gateway Metrics

Available metrics include:

TotalRequests
FailedRequests
HealthyHostCount
UnhealthyHostCount
CurrentConnections
NewConnectionsPerSecond
BackendResponseStatus
ApplicationGatewayTotalTime
BackendConnectTime
BackendFirstByteResponseTime
BackendLastByteResponseTime
Throughput
BytesSent
BytesReceived
Log Analytics and KQL

Application Gateway access logs are stored in:

AzureDiagnostics

Example query:

AzureDiagnostics
| where Category == "ApplicationGatewayAccessLog"
| take 10

Successful API requests can be investigated using:

AzureDiagnostics
| where Category == "ApplicationGatewayAccessLog"
| where httpStatus_d == "200"
| project TimeGenerated, host_s, requestUri_s, httpStatus_d, serverRouted_s
| order by TimeGenerated desc
End-to-End Validation

An actual Application Gateway access-log record showed:

Host: enterpriseapitask.online
Request: /api/tasks
TLS: TLSv1.3
SSL: Enabled
Backend: 10.10.2.30:8080
HTTP Status: 200

This validated successful HTTPS traffic through Application Gateway
to the backend.

Alert Rules

The project contains the following alert rules:

alert-appgw-unhealthy-dev
alert-storage-availability-dev
alert-sql-cpu-dev
Application Gateway

Detects unhealthy backend conditions.

Storage

Monitors storage availability.

SQL

Monitors database CPU conditions.

Action Group

The alert notification mechanism is:

ag-enterprise-dev

Email notification is configured through the Action Group.

Overall Monitoring Flow
Application Gateway
       |
       +---- Logs --------> Log Analytics
       |
       +---- Metrics
       |
       +---- Alerts ------> Action Group
                              |
                              v
                            Email
Monitoring Philosophy

The project uses Azure-native observability rather than external
monitoring platforms.

The implementation uses:

Azure Monitor
Log Analytics
KQL
Metrics
Alert Rules
Action Groups


---


# 📸 Screenshots to put in GitHub


For Part 10, capture these:


1. **Log Analytics Workspace overview**
2. **Workspace retention = 30 days**
3. **Application Gateway Diagnostic Settings**
4. **Enabled Access/Firewall/Performance logs**
5. **Application Gateway Metrics**
6. **TotalRequests metric graph/table**
7. **Log Analytics Logs/KQL**
8. **Actual `/api/tasks` HTTP 200 record**
9. **Application Gateway alert**
10. **Storage alert**
11. **SQL CPU alert**
12. **Action Group + email configuration** — hide the actual email address if you want privacy


Your strongest screenshot is the one showing:


```text
enterpriseapitask.online
/api/tasks
TLSv1.3
HTTP 200
10.10.2.30:8080