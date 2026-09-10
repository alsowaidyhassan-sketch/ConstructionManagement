#!/bin/bash
mkdir -p src/Domain/Entities
mkdir -p src/Application/Interfaces
mkdir -p src/Application/DTOs
mkdir -p src/Infrastructure/Data
mkdir -p src/Infrastructure/Services

# Add required packages
cd src/Infrastructure
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.2
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.2
dotnet add package BCrypt.Net-Next --version 4.0.3
dotnet add package System.IdentityModel.Tokens.Jwt --version 7.4.0
cd ../..

cat << 'CODE' > src/Domain/Entities/Entities.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities
{
    public class User
    {
        public Guid UserId { get; set; }
        public Guid? CompanyId { get; set; }
        public Guid? CustomerId { get; set; }
        public string UserName { get; set; }
        public string NormalizedUserName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string FullNameAr { get; set; }
        public byte UserType { get; set; } // 1: Company, 2: Customer
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        
        public Customer Customer { get; set; }
    }

    public class Customer
    {
        public Guid CustomerId { get; set; }
        public Guid CompanyId { get; set; }
        public string CustomerCode { get; set; }
        public string FullNameAr { get; set; }
        public string Phone { get; set; }
        public string WhatsAppNumber { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        
        public ICollection<Project> Projects { get; set; }
    }

    public class Project
    {
        public Guid ProjectId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid CustomerId { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal? CurrentContractValue { get; set; }
        public bool IsArchived { get; set; }
        
        public Customer Customer { get; set; }
        public ICollection<ProjectStage> Stages { get; set; }
        public ICollection<CustomerPayment> Payments { get; set; }
        public ICollection<ProgressUpdate> ProgressUpdates { get; set; }
    }

    public class ProjectStage
    {
        public Guid StageId { get; set; }
        public Guid ProjectId { get; set; }
        public string StageNameAr { get; set; }
        public decimal ProgressPercent { get; set; }
        public int SortOrder { get; set; }
        public Project Project { get; set; }
    }

    public class ProgressUpdate
    {
        public Guid ProgressUpdateId { get; set; }
        public Guid ProjectId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public DateTime UpdateDate { get; set; }
        public Project Project { get; set; }
        public ICollection<ProgressUpdateImage> Images { get; set; }
    }

    public class ProgressUpdateImage
    {
        public Guid ProgressUpdateImageId { get; set; }
        public Guid ProgressUpdateId { get; set; }
        public string StoragePath { get; set; }
        public ProgressUpdate ProgressUpdate { get; set; }
    }

    public class CustomerPayment
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid CustomerId { get; set; }
        public string PaymentNumber { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte Status { get; set; } // 1: Pending, 2: Confirmed, 3: Rejected
        
        public Project Project { get; set; }
        public Customer Customer { get; set; }
    }
}
CODE

cat << 'CODE' > src/Infrastructure/Data/ApplicationDbContext.cs
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
CODE

cat << 'CODE' > src/Application/Interfaces/ISecurityService.cs
using System.Threading.Tasks;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.Application.Interfaces
{
    public interface ISecurityService
    {
        string HashPassword(string password);
        bool VerifyPassword(string password, string hash);
        string GenerateJwtToken(User user);
    }
}
CODE

cat << 'CODE' > src/Infrastructure/Services/SecurityService.cs
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Domain.Entities;
using Microsoft.IdentityModel.Tokens;

namespace ConstructionManagement.Infrastructure.Services
{
    public class SecurityService : ISecurityService
    {
        private readonly string _secret = "YourSuperSecretKeyForJwtAuthenticationMustBeAtLeast32BytesLength!";

        public string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.EnhancedHashPassword(password, 13);
        }

        public bool VerifyPassword(string password, string hash)
        {
            return BCrypt.Net.BCrypt.EnhancedVerify(password, hash);
        }

        public string GenerateJwtToken(User user)
        {
            var handler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_secret);
            var descriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                    new Claim(ClaimTypes.Name, user.UserName),
                    new Claim("CompanyId", user.CompanyId?.ToString() ?? ""),
                    new Claim("CustomerId", user.CustomerId?.ToString() ?? ""),
                    new Claim("UserType", user.UserType.ToString())
                }),
                Expires = DateTime.UtcNow.AddHours(4),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = handler.CreateToken(descriptor);
            return handler.WriteToken(token);
        }
    }
}
CODE
