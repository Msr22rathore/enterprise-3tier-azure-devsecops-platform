using EnterpriseTask.Api.DTOs.Tasks;
namespace EnterpriseTask.Api.Services.Interfaces;
public interface ITaskService { Task<IReadOnlyList<TaskResponseDto>> GetAllAsync(CancellationToken ct); Task<TaskResponseDto?> GetByIdAsync(int id,CancellationToken ct); Task<TaskResponseDto> CreateAsync(CreateTaskDto dto,CancellationToken ct); Task<TaskResponseDto?> UpdateAsync(int id,UpdateTaskDto dto,CancellationToken ct); Task<bool> ArchiveAsync(int id,CancellationToken ct);Task<bool> DeleteAsync(int id, CancellationToken ct); }
