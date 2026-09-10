#!/bin/bash

cd src/Api/ConstructionManagement.Api
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.2
dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.2
cd ../../..

cat << 'CODE' > src/Api/ConstructionManagement.Api/Program.cs
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
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[] { }
        }
    });
});

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<ISecurityService, SecurityService>();

var key = Encoding.ASCII.GetBytes("YourSuperSecretKeyForJwtAuthenticationMustBeAtLeast32BytesLength!");
builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
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

// Apply migrations at startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.Migrate();
}

app.Run();
CODE

cat << 'CODE' > src/Api/ConstructionManagement.Api/Controllers/AuthController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ISecurityService _securityService;

        public AuthController(ApplicationDbContext context, ISecurityService securityService)
        {
            _context = context;
            _securityService = securityService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == request.UserName && u.IsActive);
            if (user == null || !_securityService.VerifyPassword(request.Password, user.PasswordHash))
                return Unauthorized(new { Message = "بيانات الدخول غير صحيحة" });

            var token = _securityService.GenerateJwtToken(user);
            return Ok(new { Token = token, FullName = user.FullNameAr, UserType = user.UserType });
        }
    }

    public class LoginRequest
    {
        public string UserName { get; set; }
        public string Password { get; set; }
    }
}
CODE

cat << 'CODE' > src/Api/ConstructionManagement.Api/Controllers/ProjectsController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using System;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ProjectsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public ProjectsController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetProjects()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;

            var query = _context.Projects.Include(p => p.Customer).AsQueryable();

            // Customer Isolation Security Rule
            if (userType == "2" && !string.IsNullOrEmpty(customerIdStr) && Guid.TryParse(customerIdStr, out Guid customerId))
            {
                query = query.Where(p => p.CustomerId == customerId);
            }

            var projects = await query.ToListAsync();
            return Ok(projects);
        }

        [HttpPost("{projectId}/progress")]
        public async Task<IActionResult> AddProgressUpdate(Guid projectId, [FromBody] ProgressUpdate update)
        {
            if (update.Images != null && update.Images.Count > 5)
            {
                return BadRequest(new { Message = "يُسمح بحد أقصى 5 صور لكل تحديث إنجاز." });
            }

            update.ProjectId = projectId;
            update.UpdateDate = DateTime.UtcNow;
            
            _context.ProgressUpdates.Add(update);
            await _context.SaveChangesAsync();
            return Ok(update);
        }
    }
}
CODE
