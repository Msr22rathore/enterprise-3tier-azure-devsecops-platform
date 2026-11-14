using EnterpriseTask.Api.DTOs.Tasks; using EnterpriseTask.Api.Models; using EnterpriseTask.Api.Repositories.Interfaces; using EnterpriseTask.Api.Services.Interfaces;
namespace EnterpriseTask.Api.Services;
public class TaskService(ITaskRepository repo):ITaskService {
 public async Task<IReadOnlyList<TaskResponseDto>> GetAllAsync(CancellationToken ct)=> (await repo.GetAllAsync(ct)).Select(Map).ToList();
 public async Task<TaskResponseDto?> GetByIdAsync(int id,CancellationToken ct){var x=await repo.GetByIdAsync(id,ct);return x is null?null:Map(x);}
 public async Task<TaskResponseDto> CreateAsync(CreateTaskDto dto,CancellationToken ct){var x=new TaskItem{Title=dto.Title.Trim(),Description=dto.Description.Trim(),Priority=dto.Priority,UserId=dto.UserId,Status="Pending"};await repo.AddAsync(x,ct);await repo.SaveChangesAsync(ct);x=await repo.GetByIdAsync(x.Id,ct)??throw new InvalidOperationException("Task was not created");x.History.Add(new TaskHistory{TaskId=x.Id,Status=x.Status});await repo.SaveChangesAsync(ct);return Map(x);}
 public async Task<TaskResponseDto?> UpdateAsync(int id,UpdateTaskDto dto,CancellationToken ct){var x=await repo.GetByIdAsync(id,ct);if(x is null)return null;var changed=x.Status!=dto.Status;x.Title=dto.Title.Trim();x.Description=dto.Description.Trim();x.Priority=dto.Priority;x.Status=dto.Status;x.UpdatedAt=DateTime.UtcNow;if(changed)x.History.Add(new TaskHistory{TaskId=x.Id,Status=x.Status});await repo.SaveChangesAsync(ct);return Map(x);}
 public async Task<bool> ArchiveAsync(int id,CancellationToken ct){var x=await repo.GetByIdAsync(id,ct);if(x is null)return false;x.Status="Blocked";x.UpdatedAt=DateTime.UtcNow;x.History.Add(new TaskHistory{TaskId=x.Id,Status="Blocked"});await repo.SaveChangesAsync(ct);return true;}
 static TaskResponseDto Map(TaskItem x)=>new(x.Id,x.Title,x.Description,x.Status,x.Priority,x.CreatedAt,x.UpdatedAt,x.UserId,x.User.Name,x.User.Email);public async Task<bool> DeleteAsync(
    int id,
    CancellationToken ct)
{
    var x = await repo.GetByIdAsync(id, ct);

    if (x is null)
        return false;

    await repo.DeleteAsync(x, ct);

    await repo.SaveChangesAsync(ct);

    return true;
}
}
