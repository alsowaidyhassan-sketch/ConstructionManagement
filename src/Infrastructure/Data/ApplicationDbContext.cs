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
        public DbSet<ChangeOrder> ChangeOrders { get; set; }
        public DbSet<Expense> Expenses { get; set; }
        public DbSet<Document> Documents { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<User>(e => { e.ToTable("Users", "Security"); e.HasKey(x => x.UserId); });
            modelBuilder.Entity<Customer>(e => { e.ToTable("Customers", "Core"); e.HasKey(x => x.CustomerId); });
            modelBuilder.Entity<Project>(e => { e.ToTable("Projects", "Projects"); e.HasKey(x => x.ProjectId); });
            modelBuilder.Entity<ProjectStage>(e => { e.ToTable("ProjectStages", "Projects"); e.HasKey(x => x.StageId); });
            modelBuilder.Entity<ProgressUpdate>(e => { e.ToTable("ProgressUpdates", "Projects"); e.HasKey(x => x.ProgressUpdateId); });
            modelBuilder.Entity<ProgressUpdateImage>(e => { e.ToTable("ProgressUpdateImages", "Files"); e.HasKey(x => x.ProgressUpdateImageId); });
            modelBuilder.Entity<CustomerPayment>(e => { e.ToTable("CustomerPayments", "Finance"); e.HasKey(x => x.PaymentId); });
            modelBuilder.Entity<ChangeOrder>(e => { e.ToTable("ChangeOrders", "Projects"); e.HasKey(x => x.ChangeOrderId); });
            modelBuilder.Entity<Expense>(e => { e.ToTable("Expenses", "Finance"); e.HasKey(x => x.ExpenseId); });
            modelBuilder.Entity<Document>(e => { e.ToTable("Documents", "Files"); e.HasKey(x => x.DocumentId); });
            modelBuilder.Entity<AuditLog>(e => { e.ToTable("AuditLogs", "Security"); e.HasKey(x => x.AuditLogId); });
        }
    }
}
