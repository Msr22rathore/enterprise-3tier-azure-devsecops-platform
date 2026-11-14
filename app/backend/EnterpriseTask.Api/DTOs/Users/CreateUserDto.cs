using System.ComponentModel.DataAnnotations;
namespace EnterpriseTask.Api.DTOs.Users;
public class CreateUserDto { [Required,MaxLength(120)] public string Name {get;set;}=""; [Required,EmailAddress,MaxLength(256)] public string Email {get;set;}=""; }
