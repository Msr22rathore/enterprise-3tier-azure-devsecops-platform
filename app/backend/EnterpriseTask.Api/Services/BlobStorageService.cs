using Azure.Identity;
using Azure.Storage.Blobs;
using EnterpriseTask.Api.Services.Interfaces;
namespace EnterpriseTask.Api.Services;
public class BlobStorageService(IConfiguration config) : IBlobStorageService
{
    public async Task<string> UploadAsync(IFormFile file, CancellationToken ct)
    {
        if (file.Length == 0) throw new ArgumentException("File is empty.");
        var accountName = config["AzureStorage:AccountName"] ?? throw new InvalidOperationException("AzureStorage:AccountName is required.");
        var containerName = config["AzureStorage:ContainerName"] ?? "task-attachments";
        var service = new BlobServiceClient(new Uri($"https://{accountName}.blob.core.windows.net"), new DefaultAzureCredential());
        var container = service.GetBlobContainerClient(containerName);
        await container.CreateIfNotExistsAsync(cancellationToken: ct);
        var blobName = $"{DateTime.UtcNow:yyyy/MM}/{Guid.NewGuid():N}-{Path.GetFileName(file.FileName)}";
        var blob = container.GetBlobClient(blobName);
        await using var stream = file.OpenReadStream();
        await blob.UploadAsync(stream, overwrite: false, cancellationToken: ct);
        return blobName;
    }
}
