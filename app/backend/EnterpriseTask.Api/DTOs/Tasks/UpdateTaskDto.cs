using System.ComponentModel.DataAnnotations;
namespace EnterpriseTask.Api.DTOs.Tasks;
public class UpdateTaskDto { [Required,MaxLength(200)] public string Title {get;set;}=""; [MaxLength(2000)] public string Description {get;set;}=""; [Required,RegularExpression("Pending|InProgress|Completed|Blocked")] public string Status {get;set;}="Pending"; [Range(1,5)] public int Priority {get;set;}=3; }
