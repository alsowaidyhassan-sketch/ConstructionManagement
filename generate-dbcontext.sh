#!/bin/bash

cat << 'CS' > src/Infrastructure/Data/ApplicationDbContext.cs
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Files;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.System;

namespace ConstructionManagement.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        // Core
        public DbSet<Company> Companies { get; set; }
        public DbSet<Branch> Branches { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Contractor> Contractors { get; set; }

        // Security
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

        // Projects
        public DbSet<ProjectType> ProjectTypes { get; set; }
        public DbSet<Project> Projects { get; set; }
        public DbSet<ProjectStage> ProjectStages { get; set; }
        public DbSet<WorkItem> WorkItems { get; set; }
        public DbSet<ProgressUpdate> ProgressUpdates { get; set; }
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<ContractVersion> ContractVersions { get; set; }
        public DbSet<ChangeOrder> ChangeOrders { get; set; }
        public DbSet<ProjectNote> ProjectNotes { get; set; }

        // Finance
        public DbSet<PaymentPlanItem> PaymentPlanItems { get; set; }
        public DbSet<CustomerPayment> CustomerPayments { get; set; }
        public DbSet<ContractorPayment> ContractorPayments { get; set; }
        public DbSet<ExpenseType> ExpenseTypes { get; set; }
        public DbSet<Expense> Expenses { get; set; }

        // Files
        public DbSet<Document> Documents { get; set; }
        public DbSet<ProgressUpdateImage> ProgressUpdateImages { get; set; }

        // System
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<WhatsAppMessageLog> WhatsAppMessageLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Core
            modelBuilder.Entity<Company>().ToTable("Companies", "Core").HasKey(x => x.CompanyId);
            modelBuilder.Entity<Branch>().ToTable("Branches", "Core").HasKey(x => x.BranchId);
            modelBuilder.Entity<Customer>().ToTable("Customers", "Core").HasKey(x => x.CustomerId);
            modelBuilder.Entity<Contractor>().ToTable("Contractors", "Core").HasKey(x => x.ContractorId);

            // Security
            modelBuilder.Entity<User>().ToTable("Users", "Security").HasKey(x => x.UserId);
            modelBuilder.Entity<Role>().ToTable("Roles", "Security").HasKey(x => x.RoleId);
            modelBuilder.Entity<UserRole>().ToTable("UserRoles", "Security").HasKey(x => new { x.UserId, x.RoleId });
            modelBuilder.Entity<Permission>().ToTable("Permissions", "Security").HasKey(x => x.PermissionId);
            modelBuilder.Entity<RolePermission>().ToTable("RolePermissions", "Security").HasKey(x => new { x.RoleId, x.PermissionId });
            modelBuilder.Entity<AuditLog>().ToTable("AuditLogs", "Security").HasKey(x => x.AuditLogId);

            // Projects
            modelBuilder.Entity<ProjectType>().ToTable("ProjectTypes", "Projects").HasKey(x => x.ProjectTypeId);
            modelBuilder.Entity<Project>().ToTable("Projects", "Projects").HasKey(x => x.ProjectId);
            modelBuilder.Entity<ProjectStage>().ToTable("ProjectStages", "Projects").HasKey(x => x.StageId);
            modelBuilder.Entity<WorkItem>().ToTable("WorkItems", "Projects").HasKey(x => x.WorkItemId);
            modelBuilder.Entity<ProgressUpdate>().ToTable("ProgressUpdates", "Projects").HasKey(x => x.ProgressUpdateId);
            modelBuilder.Entity<Contract>().ToTable("Contracts", "Projects").HasKey(x => x.ContractId);
            modelBuilder.Entity<ContractVersion>().ToTable("ContractVersions", "Projects").HasKey(x => x.VersionId);
            modelBuilder.Entity<ChangeOrder>().ToTable("ChangeOrders", "Projects").HasKey(x => x.ChangeOrderId);
            modelBuilder.Entity<ProjectNote>().ToTable("ProjectNotes", "Projects").HasKey(x => x.NoteId);

            // Finance
            modelBuilder.Entity<PaymentPlanItem>().ToTable("PaymentPlanItems", "Finance").HasKey(x => x.PaymentPlanItemId);
            modelBuilder.Entity<CustomerPayment>().ToTable("CustomerPayments", "Finance").HasKey(x => x.PaymentId);
            modelBuilder.Entity<ContractorPayment>().ToTable("ContractorPayments", "Finance").HasKey(x => x.PaymentId);
            modelBuilder.Entity<ExpenseType>().ToTable("ExpenseTypes", "Finance").HasKey(x => x.ExpenseTypeId);
            modelBuilder.Entity<Expense>().ToTable("Expenses", "Finance").HasKey(x => x.ExpenseId);

            // Files
            modelBuilder.Entity<Document>().ToTable("Documents", "Files").HasKey(x => x.DocumentId);
            modelBuilder.Entity<ProgressUpdateImage>().ToTable("ProgressUpdateImages", "Files").HasKey(x => x.ProgressUpdateImageId);

            // System
            modelBuilder.Entity<Notification>().ToTable("Notifications", "System").HasKey(x => x.NotificationId);
            modelBuilder.Entity<WhatsAppMessageLog>().ToTable("WhatsAppMessageLogs", "System").HasKey(x => x.LogId);

            // Relationships & Precision Adjustments
            
            // Disable cascading deletes on highly connected entities to prevent accidental widespread data loss
            foreach (var relationship in modelBuilder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
            {
                relationship.DeleteBehavior = DeleteBehavior.Restrict;
            }

            modelBuilder.Entity<ProgressUpdateImage>()
                .HasOne(p => p.ProgressUpdate)
                .WithMany(u => u.Images)
                .HasForeignKey(p => p.ProgressUpdateId)
                .OnDelete(DeleteBehavior.Cascade); // Except for images on a progress update, this is fine

            modelBuilder.Entity<ContractVersion>()
                .HasOne(cv => cv.Contract)
                .WithMany(c => c.Versions)
                .HasForeignKey(cv => cv.ContractId)
                .OnDelete(DeleteBehavior.Cascade);
                
            modelBuilder.Entity<WorkItem>()
                .HasOne(w => w.Stage)
                .WithMany(s => s.WorkItems)
                .HasForeignKey(w => w.StageId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ProjectStage>()
                .HasOne(s => s.ParentStage)
                .WithMany(p => p.SubStages)
                .HasForeignKey(s => s.ParentStageId);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Role)
                .WithMany(r => r.RolePermissions)
                .HasForeignKey(rp => rp.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(rp => rp.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);
                
            // Decimal Precisions
            var decimalProps = modelBuilder.Model.GetEntityTypes()
                .SelectMany(t => t.GetProperties())
                .Where(p => p.ClrType == typeof(decimal) || p.ClrType == typeof(decimal?));
            foreach (var property in decimalProps)
            {
                property.SetColumnType("decimal(18, 4)");
            }
            
            // Unique constraints
            modelBuilder.Entity<Customer>().HasIndex(c => c.CustomerCode).IsUnique();
            modelBuilder.Entity<Project>().HasIndex(p => p.ProjectCode).IsUnique();
        }
    }
}
CS
