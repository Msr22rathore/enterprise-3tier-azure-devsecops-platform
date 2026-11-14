# EF Core database

The schema is owned by EF Core migrations.

Install EF CLI if needed:
dotnet tool install --global dotnet-ef

From backend/EnterpriseTask.Api:
dotnet ef migrations add InitialCreate
dotnet ef database update

The development API also applies pending migrations automatically because Database:ApplyMigrations=true in appsettings.Development.json. For production, use a controlled migration stage/job and keep API replicas from racing migrations.
