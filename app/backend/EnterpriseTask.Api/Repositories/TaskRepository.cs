using EnterpriseTask.Api.Data; using EnterpriseTask.Api.Models; using EnterpriseTask.Api.Repositories.Interfaces; using Microsoft.EntityFrameworkCore;
namespace EnterpriseTask.Api.Repositories;
public class TaskRepository(ApplicationDbContext db):ITaskRepository {
 public Task<List<TaskItem>> GetAllAsync(CancellationToken ct)=>db.Tasks.AsNoTracking().Include(x=>x.User).OrderByDescending(x=>x.CreatedAt).ToListAsync(ct);
 public Task<TaskItem?> GetByIdAsync(int id,CancellationToken ct)=>db.Tasks.Include(x=>x.User).Include(x=>x.History).FirstOrDefaultAsync(x=>x.Id==id,ct);
 public async Task AddAsync(TaskItem entity,CancellationToken ct)=>await db.Tasks.AddAsync(entity,ct);
 public Task SaveChangesAsync(CancellationToken ct)=>db.SaveChangesAsync(ct);
 public Task DeleteAsync(TaskItem entity,CancellationToken ct){db.Tasks.Remove(entity);return Task.CompletedTask;}
}
