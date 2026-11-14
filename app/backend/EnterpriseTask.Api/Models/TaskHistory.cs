namespace EnterpriseTask.Api.Models;
public class TaskHistory { public int Id {get;set;} public int TaskId {get;set;} public string Status {get;set;}=""; public DateTime ChangedAt {get;set;}=DateTime.UtcNow; public TaskItem Task {get;set;}=null!; }
