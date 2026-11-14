using EnterpriseTask.Api.Data;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace EnterpriseTask.Api.Health;

public class DatabaseHealthCheck(
    ApplicationDbContext db,
    ILogger<DatabaseHealthCheck> logger) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext c,
        CancellationToken ct = default)
    {
        try
        {
            return await db.Database.CanConnectAsync(ct)
                ? HealthCheckResult.Healthy("Database connection is healthy.")
                : HealthCheckResult.Unhealthy("Database connection failed.");
        }
        catch (Exception ex)
        {
            logger.LogError(
                ex,
                "DATABASE CONNECTION FAILED. Type={ExceptionType}, Message={Message}",
                ex.GetType().FullName,
                ex.Message);

            return HealthCheckResult.Unhealthy(
                "Database connection failed.",
                ex);
        }
    }
}