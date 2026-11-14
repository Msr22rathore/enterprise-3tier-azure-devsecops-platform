using EnterpriseTask.Api.Models;
using Microsoft.EntityFrameworkCore;
namespace EnterpriseTask.Api.Data;
public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<TaskItem> Tasks => Set<TaskItem>();
    public DbSet<TaskHistory> TaskHistory => Set<TaskHistory>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>(e => { e.ToTable("Users"); e.HasKey(x=>x.Id); e.Property(x=>x.Name).HasMaxLength(120).IsRequired(); e.Property(x=>x.Email).HasMaxLength(256).IsRequired(); e.HasIndex(x=>x.Email).IsUnique(); });
        b.Entity<TaskItem>(e => { e.ToTable("Tasks"); e.HasKey(x=>x.Id); e.Property(x=>x.Title).HasMaxLength(200).IsRequired(); e.Property(x=>x.Description).HasMaxLength(2000); e.Property(x=>x.Status).HasMaxLength(30).IsRequired(); e.HasOne(x=>x.User).WithMany(x=>x.Tasks).HasForeignKey(x=>x.UserId).OnDelete(DeleteBehavior.Restrict); });
        b.Entity<TaskHistory>(e => { e.ToTable("TaskHistory"); e.HasKey(x=>x.Id); e.Property(x=>x.Status).HasMaxLength(30).IsRequired(); e.HasOne(x=>x.Task).WithMany(x=>x.History).HasForeignKey(x=>x.TaskId).OnDelete(DeleteBehavior.Cascade); });
    }
}
