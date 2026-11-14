using System.Text.Json;
namespace EnterpriseTask.Api.Middleware;
public class ExceptionMiddleware(RequestDelegate next,ILogger<ExceptionMiddleware> logger){public async Task Invoke(HttpContext context){try{await next(context);}catch(Exception ex){logger.LogError(ex,"Unhandled exception. TraceId: {TraceId}",context.TraceIdentifier);context.Response.StatusCode=500;context.Response.ContentType="application/json";await context.Response.WriteAsync(JsonSerializer.Serialize(new{status=500,message="An unexpected error occurred.",traceId=context.TraceIdentifier}));}}}
