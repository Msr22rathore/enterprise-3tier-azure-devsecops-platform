namespace EnterpriseTask.Api.Services.Interfaces;
public interface IBlobStorageService { Task<string> UploadAsync(IFormFile file, CancellationToken ct); }
