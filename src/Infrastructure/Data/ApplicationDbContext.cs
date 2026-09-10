using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("Users", "Security");
                entity.HasKey(e => e.UserId);
            });
        }
    }
}
