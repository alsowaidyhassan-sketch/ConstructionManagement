#!/bin/bash
mkdir -p src/Application/DTOs
mkdir -p src/Application/Interfaces
mkdir -p src/Infrastructure/Services

# AppSettings
cat << 'JSON' > src/Api/ConstructionManagement.Api/appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=ConstructionManagementDB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
  },
  "JwtSettings": {
    "Secret": "YourSuperSecretKeyForJwtAuthenticationMustBeAtLeast32Bytes_UPDATED_SECURE_KEY",
    "Issuer": "ConstructionManagementApi",
    "Audience": "ConstructionManagementClients",
    "ExpiryMinutes": 120
  },
  "FileStorage": {
    "BasePath": "Uploads"
  }
}
JSON

# Interfaces
cat << 'CS' > src/Application/Interfaces/Interfaces.cs
using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IFileStorage
    {
        Task<string> SaveFileAsync(byte[] content, string fileName, string path);
        Task<byte[]> GetFileAsync(string filePath);
    }
    
    public interface IPaymentGateway
    {
        Task<string> CreateTransactionAsync(decimal amount, string currency, string reference);
        Task<bool> VerifyTransactionAsync(string transactionId);
    }

    public interface IWhatsAppProvider
    {
        Task<bool> SendMessageAsync(string phone, string message);
    }
}
CS

# DTOs
cat << 'CS' > src/Application/DTOs/Dtos.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ProjectDto
    {
        public Guid ProjectId { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal? CurrentContractValue { get; set; }
    }
    
    public class ChangeOrderDto
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; }
    }

    public class ProgressUpdateDto
    {
        public Guid ProjectId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public List<string> Base64Images { get; set; }
    }
}
CS

# Extended Entities
cat << 'CS' > src/Domain/Entities/ExtendedEntities.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities
{
    public class ChangeOrder
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; } // 1: Draft, 2: Pending, 3: Approved, 4: Rejected
        public DateTime CreatedAtUtc { get; set; }
        
        public Project Project { get; set; }
    }

    public class Expense
    {
        public Guid ExpenseId { get; set; }
        public Guid? ProjectId { get; set; } // Null means Company Expense
        public string Category { get; set; }
        public decimal Amount { get; set; }
        public DateTime ExpenseDate { get; set; }
        public string Notes { get; set; }
        
        public Project Project { get; set; }
    }

    public class Document
    {
        public Guid DocumentId { get; set; }
        public Guid? ProjectId { get; set; }
        public Guid? CustomerId { get; set; }
        public string FileName { get; set; }
        public string StoragePath { get; set; }
        public bool IsCustomerVisible { get; set; }
        
        public Project Project { get; set; }
    }
    
    public class AuditLog
    {
        public Guid AuditLogId { get; set; }
        public Guid UserId { get; set; }
        public string Action { get; set; }
        public string EntityName { get; set; }
        public string Details { get; set; }
        public DateTime TimestampUtc { get; set; }
    }
}
CS

# Update DbContext
cat << 'CS' > src/Infrastructure/Data/ApplicationDbContext.cs
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
CS

# Infrastructure Services
cat << 'CS' > src/Infrastructure/Services/InfrastructureServices.cs
using System;
using System.IO;
using System.Threading.Tasks;
using ConstructionManagement.Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace ConstructionManagement.Infrastructure.Services
{
    public class LocalFileStorageService : IFileStorage
    {
        private readonly string _basePath;
        public LocalFileStorageService(IConfiguration config)
        {
            _basePath = config["FileStorage:BasePath"] ?? "Uploads";
            if (!Directory.Exists(_basePath)) Directory.CreateDirectory(_basePath);
        }

        public async Task<string> SaveFileAsync(byte[] content, string fileName, string path)
        {
            var fullPath = Path.Combine(_basePath, path);
            if (!Directory.Exists(fullPath)) Directory.CreateDirectory(fullPath);
            var filePath = Path.Combine(fullPath, fileName);
            await File.WriteAllBytesAsync(filePath, content);
            return Path.Combine(path, fileName).Replace("\\", "/");
        }

        public async Task<byte[]> GetFileAsync(string filePath)
        {
            var fullPath = Path.Combine(_basePath, filePath);
            if (File.Exists(fullPath)) return await File.ReadAllBytesAsync(fullPath);
            return null;
        }
    }

    public class MockPaymentGateway : IPaymentGateway
    {
        public Task<string> CreateTransactionAsync(decimal amount, string currency, string reference) => Task.FromResult(Guid.NewGuid().ToString());
        public Task<bool> VerifyTransactionAsync(string transactionId) => Task.FromResult(true);
    }

    public class MockWhatsAppProvider : IWhatsAppProvider
    {
        public Task<bool> SendMessageAsync(string phone, string message) => Task.FromResult(true);
    }
}
CS

# Controllers
cat << 'CS' > src/Api/ConstructionManagement.Api/Controllers/SystemControllers.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using System;
using ConstructionManagement.Domain.Entities;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Application.Interfaces;
using System.Collections.Generic;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public DashboardController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetDashboardStats()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;
            bool isCustomer = userType == "2";
            
            var projectsQuery = _context.Projects.AsQueryable();
            var paymentsQuery = _context.CustomerPayments.AsQueryable();
            
            if (isCustomer && Guid.TryParse(customerIdStr, out Guid customerId))
            {
                projectsQuery = projectsQuery.Where(p => p.CustomerId == customerId);
                paymentsQuery = paymentsQuery.Where(p => p.CustomerId == customerId);
            }

            var totalProjects = await projectsQuery.CountAsync();
            var totalPayments = await paymentsQuery.SumAsync(p => p.Amount);

            return Ok(new { TotalProjects = totalProjects, TotalPayments = totalPayments });
        }
    }

    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ChangeOrdersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public ChangeOrdersController(ApplicationDbContext context) { _context = context; }

        [HttpPost("{id}/approve")]
        public async Task<IActionResult> ApproveChangeOrder(Guid id)
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            if (userType == "2") return Forbid("Customers cannot approve change orders."); // Customer Isolation - Prevent unauthorized action

            var changeOrder = await _context.ChangeOrders.Include(c => c.Project).FirstOrDefaultAsync(c => c.ChangeOrderId == id);
            if (changeOrder == null) return NotFound();

            changeOrder.Status = 3; // Approved
            if (changeOrder.Project != null)
            {
                changeOrder.Project.CurrentContractValue = (changeOrder.Project.CurrentContractValue ?? 0) + changeOrder.AmountChange;
            }
            
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), Action = "Approve", EntityName = "ChangeOrder", Details = $"Approved CO {id}", TimestampUtc = DateTime.UtcNow });
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Approved successfully." });
        }
    }

    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ProgressController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileStorage _fileStorage;
        public ProgressController(ApplicationDbContext context, IFileStorage fileStorage) 
        { 
            _context = context;
            _fileStorage = fileStorage;
        }

        [HttpPost]
        public async Task<IActionResult> CreateProgressUpdate([FromBody] ProgressUpdateDto dto)
        {
            if (dto.Base64Images != null && dto.Base64Images.Count > 5)
                return BadRequest(new { Message = "يسمح بحد أقصى 5 صور فقط" });

            var update = new ProgressUpdate
            {
                ProgressUpdateId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                ProgressPercent = dto.ProgressPercent,
                Description = dto.Description,
                UpdateDate = DateTime.UtcNow,
                Images = new List<ProgressUpdateImage>()
            };

            if (dto.Base64Images != null)
            {
                foreach (var img in dto.Base64Images)
                {
                    var bytes = Convert.FromBase64String(img);
                    var path = await _fileStorage.SaveFileAsync(bytes, $"{Guid.NewGuid()}.jpg", $"Projects/{dto.ProjectId}/Progress");
                    update.Images.Add(new ProgressUpdateImage { ProgressUpdateImageId = Guid.NewGuid(), StoragePath = path });
                }
            }

            _context.ProgressUpdates.Add(update);
            await _context.SaveChangesAsync();
            return Ok(update);
        }
    }
}
CS

# Security Service Update to use IConfiguration
cat << 'CS' > src/Infrastructure/Services/SecurityService.cs
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace ConstructionManagement.Infrastructure.Services
{
    public class SecurityService : ISecurityService
    {
        private readonly string _secret;

        public SecurityService(IConfiguration configuration)
        {
            _secret = configuration["JwtSettings:Secret"] ?? "FallbackSecretKeyThatShouldBeChangedInProdAtLeast32Bytes";
        }

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
CS

# Program.cs Update
cat << 'CS' > src/Api/ConstructionManagement.Api/Program.cs
using System.Text;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Construction Management API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }, new string[] { } }
    });
});

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<ISecurityService, SecurityService>();
builder.Services.AddScoped<IFileStorage, LocalFileStorageService>();
builder.Services.AddScoped<IPaymentGateway, MockPaymentGateway>();
builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();

var secret = builder.Configuration["JwtSettings:Secret"] ?? "FallbackSecretKeyThatShouldBeChangedInProdAtLeast32Bytes";
var key = Encoding.ASCII.GetBytes(secret);

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false; // In production this should be true if behind load balancer without SSL termination
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    // db.Database.Migrate(); // Migrations handled explicitly in deployment
}

app.Run();
CS

