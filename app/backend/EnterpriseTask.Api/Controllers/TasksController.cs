using EnterpriseTask.Api.DTOs.Tasks; using EnterpriseTask.Api.Services.Interfaces; using Microsoft.AspNetCore.Mvc;
namespace EnterpriseTask.Api.Controllers;
[ApiController][Route("api/tasks")]
public class TasksController(ITaskService service):ControllerBase {
 [HttpGet] public async Task<ActionResult<IReadOnlyList<TaskResponseDto>>> GetAll(CancellationToken ct)=>Ok(await service.GetAllAsync(ct));
 [HttpGet("{id:int}")] public async Task<ActionResult<TaskResponseDto>> Get(int id,CancellationToken ct){var x=await service.GetByIdAsync(id,ct);return x is null?NotFound():Ok(x);}
 [HttpPost] public async Task<ActionResult<TaskResponseDto>> Create(CreateTaskDto dto,CancellationToken ct){var x=await service.CreateAsync(dto,ct);return CreatedAtAction(nameof(Get),new{id=x.Id},x);}
 [HttpPut("{id:int}")] public async Task<ActionResult<TaskResponseDto>> Update(int id,UpdateTaskDto dto,CancellationToken ct){var x=await service.UpdateAsync(id,dto,ct);return x is null?NotFound():Ok(x);}
 [HttpDelete("{id:int}")]
public async Task<IActionResult> Delete(
    int id,
    CancellationToken ct)
{
    var deleted = await service.DeleteAsync(id, ct);

    if (!deleted)
        return NotFound();

    return NoContent();
}
}
