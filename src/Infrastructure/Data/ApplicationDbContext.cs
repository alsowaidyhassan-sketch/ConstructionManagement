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
        public DbSet<ProjectStage> ProjectStages { get; set; }
        public DbSet<ProgressUpdate> ProgressUpdates { get; set; }
        public DbSet<ProgressUpdateImage> ProgressUpdateImages { get; set; }
        public DbSet<CustomerPayment> CustomerPayments { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<User>(e => { 
                e.ToTable("Users", "Security"); 
                e.HasKey(x => x.UserId);
                e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId);
            });

            modelBuilder.Entity<Customer>(e => { 
                e.ToTable("Customers", "Core"); 
                e.HasKey(x => x.CustomerId); 
            });

            modelBuilder.Entity<Project>(e => { 
                e.ToTable("Projects", "Projects"); 
                e.HasKey(x => x.ProjectId);
                e.HasOne(x => x.Customer).WithMany(c => c.Projects).HasForeignKey(x => x.CustomerId);
            });

            modelBuilder.Entity<ProjectStage>(e => {
                e.ToTable("ProjectStages", "Projects");
                e.HasKey(x => x.StageId);
                e.HasOne(x => x.Project).WithMany(p => p.Stages).HasForeignKey(x => x.ProjectId);
            });

            modelBuilder.Entity<ProgressUpdate>(e => {
                e.ToTable("ProgressUpdates", "Projects");
                e.HasKey(x => x.ProgressUpdateId);
                e.HasOne(x => x.Project).WithMany(p => p.ProgressUpdates).HasForeignKey(x => x.ProjectId);
            });

            modelBuilder.Entity<ProgressUpdateImage>(e => {
                e.ToTable("ProgressUpdateImages", "Files");
                e.HasKey(x => x.ProgressUpdateImageId);
                e.HasOne(x => x.ProgressUpdate).WithMany(p => p.Images).HasForeignKey(x => x.ProgressUpdateId);
            });

            modelBuilder.Entity<CustomerPayment>(e => {
                e.ToTable("CustomerPayments", "Finance");
                e.HasKey(x => x.PaymentId);
                e.HasOne(x => x.Project).WithMany(p => p.Payments).HasForeignKey(x => x.ProjectId);
                e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId).OnDelete(DeleteBehavior.NoAction);
            });
        }
    }
}
