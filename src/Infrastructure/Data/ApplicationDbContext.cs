using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Project> Projects { get; set; }
        public DbSet<CustomerPayment> CustomerPayments { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<User>(e => { e.ToTable("Users", "Security"); e.HasKey(x => x.UserId); });
            modelBuilder.Entity<Customer>(e => { e.ToTable("Customers", "Core"); e.HasKey(x => x.CustomerId); });
            modelBuilder.Entity<Project>(e => { 
                e.ToTable("Projects", "Projects"); 
                e.HasKey(x => x.ProjectId); 
                e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId);
            });
            modelBuilder.Entity<CustomerPayment>(e => { e.ToTable("CustomerPayments", "Finance"); e.HasKey(x => x.PaymentId); });
        }
    }
}
