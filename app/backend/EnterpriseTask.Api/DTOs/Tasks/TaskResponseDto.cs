namespace EnterpriseTask.Api.DTOs.Tasks;
public record TaskResponseDto(int Id,string Title,string Description,string Status,int Priority,DateTime CreatedAt,DateTime? UpdatedAt,int UserId,string UserName,string UserEmail);
