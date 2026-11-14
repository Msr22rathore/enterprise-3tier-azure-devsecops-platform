using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore.Diagnostics;
using System.Data.Common;

namespace EnterpriseTask.Api.Services;

public sealed class AzureSqlAccessTokenInterceptor : DbConnectionInterceptor
{
    private readonly DefaultAzureCredential _credential = new();
    private readonly ILogger<AzureSqlAccessTokenInterceptor> _logger;

    public AzureSqlAccessTokenInterceptor(
        ILogger<AzureSqlAccessTokenInterceptor> logger)
    {
        _logger = logger;
    }

    public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(
        DbConnection connection,
        ConnectionEventData eventData,
        InterceptionResult result,
        CancellationToken cancellationToken = default)
    {
        if (connection is SqlConnection sqlConnection)
        {
            _logger.LogInformation(
                "Azure SQL interceptor invoked. Server={Server}, Database={Database}",
                sqlConnection.DataSource,
                sqlConnection.Database);

            try
            {
                AccessToken token = await _credential.GetTokenAsync(
                    new TokenRequestContext(
                        new[] { "https://database.windows.net/.default" }),
                    cancellationToken);

                sqlConnection.AccessToken = token.Token;

                _logger.LogInformation(
                    "Azure SQL access token acquired successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "FAILED TO ACQUIRE AZURE SQL ACCESS TOKEN. Type={ExceptionType}, Message={Message}",
                    ex.GetType().FullName,
                    ex.Message);

                throw;
            }
        }

        return result;
    }
}