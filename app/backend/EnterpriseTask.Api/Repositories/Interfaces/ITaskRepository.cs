using EnterpriseTask.Api.Models;
namespace EnterpriseTask.Api.Repositories.Interfaces;
public interface ITaskRepository { Task<List<TaskItem>> GetAllAsync(CancellationToken ct); Task<TaskItem?> GetByIdAsync(int id,CancellationToken ct); Task AddAsync(TaskItem entity,CancellationToken ct); Task SaveChangesAsync(CancellationToken ct);Task DeleteAsync(TaskItem entity,CancellationToken ct); }
