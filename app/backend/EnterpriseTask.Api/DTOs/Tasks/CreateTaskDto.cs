using System.ComponentModel.DataAnnotations;
namespace EnterpriseTask.Api.DTOs.Tasks;
public class CreateTaskDto { [Required,MaxLength(200)] public string Title {get;set;}=""; [MaxLength(2000)] public string Description {get;set;}=""; [Range(1,5)] public int Priority {get;set;}=3; [Range(1,int.MaxValue)] public int UserId {get;set;} }
