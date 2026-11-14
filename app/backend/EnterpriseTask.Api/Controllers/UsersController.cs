using EnterpriseTask.Api.Data; using EnterpriseTask.Api.DTOs.Users; using EnterpriseTask.Api.Models; using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore;
namespace EnterpriseTask.Api.Controllers;
[ApiController][Route("api/users")]
public class UsersController(ApplicationDbContext db):ControllerBase {
 [HttpGet] public async Task<IActionResult> GetAll(CancellationToken ct)=>Ok(await db.Users.AsNoTracking().OrderBy(x=>x.Name).Select(x=>new{x.Id,x.Name,x.Email}).ToListAsync(ct));
 [HttpPost] public async Task<IActionResult> Create(CreateUserDto dto,CancellationToken ct){var email=dto.Email.Trim().ToLowerInvariant();if(await db.Users.AnyAsync(x=>x.Email==email,ct))return Conflict(new{message="A user with this email already exists."});var u=new User{Name=dto.Name.Trim(),Email=email};db.Users.Add(u);await db.SaveChangesAsync(ct);return Created($"/api/users/{u.Id}",new{u.Id,u.Name,u.Email});}
}
