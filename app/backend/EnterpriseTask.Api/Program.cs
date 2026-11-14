using EnterpriseTask.Api.Data;
using EnterpriseTask.Api.Health;
using EnterpriseTask.Api.Middleware;
using EnterpriseTask.Api.Repositories;
using EnterpriseTask.Api.Repositories.Interfaces;
using EnterpriseTask.Api.Services;
using EnterpriseTask.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var cs = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("DefaultConnection missing");
builder.Services.AddSingleton<AzureSqlAccessTokenInterceptor>();
builder.Services.AddDbContext<ApplicationDbContext>((sp, o) =>
{
    o.UseSqlServer(cs, sql => sql.EnableRetryOnFailure(5, TimeSpan.FromSeconds(10), null).CommandTimeout(30));
    if (builder.Configuration.GetValue<bool>("AzureSql:UseManagedIdentity"))
        o.AddInterceptors(sp.GetRequiredService<AzureSqlAccessTokenInterceptor>());
});
builder.Services.AddScoped<ITaskRepository, TaskRepository>();
builder.Services.AddScoped<ITaskService, TaskService>();
builder.Services.AddScoped<IBlobStorageService, BlobStorageService>();
builder.Services.AddScoped<DatabaseHealthCheck>();
builder.Services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("database");
builder.Services.AddCors(o => o.AddPolicy("Frontend", p => {
    var origins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? ["http://localhost:4200"];
    p.WithOrigins(origins).AllowAnyHeader().AllowAnyMethod();
}));
var app = builder.Build();
app.UseMiddleware<ExceptionMiddleware>();
if (app.Environment.IsDevelopment()) { app.UseSwagger(); app.UseSwaggerUI(); }
app.UseHttpsRedirection();
app.UseCors("Frontend");
app.MapControllers();
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");
if (app.Configuration.GetValue<bool>("Database:ApplyMigrations")) {
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await db.Database.EnsureCreatedAsync();
    if (!await db.Users.AnyAsync())
    {
        var user = new EnterpriseTask.Api.Models.User { Name = "Sunny", Email = "sunny@example.com" };
        db.Users.Add(user);
        await db.SaveChangesAsync();
        db.Tasks.AddRange(
            new EnterpriseTask.Api.Models.TaskItem { Title = "Provision Azure platform", Description = "Terraform infrastructure is ready.", Status = "Completed", Priority = 1, UserId = user.Id },
            new EnterpriseTask.Api.Models.TaskItem { Title = "Deploy application to AKS", Description = "Build images, push to ACR and deploy manifests.", Status = "Pending", Priority = 2, UserId = user.Id });
        await db.SaveChangesAsync();
    }
}
app.Run();
