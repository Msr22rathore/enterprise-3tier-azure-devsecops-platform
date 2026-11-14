using EnterpriseTask.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
namespace EnterpriseTask.Api.Controllers;
[ApiController][Route("api/files")]
public class FilesController(IBlobStorageService storage) : ControllerBase
{
    [HttpPost("upload")]
    [RequestSizeLimit(10_000_000)]
    public async Task<IActionResult> Upload(IFormFile file, CancellationToken ct)
    {
        if (file is null) return BadRequest(new { message = "A file is required." });
        var blobName = await storage.UploadAsync(file, ct);
        return Ok(new { blobName });
    }
}
