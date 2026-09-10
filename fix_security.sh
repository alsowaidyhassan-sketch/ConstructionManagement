#!/bin/bash

# 1. Update appsettings.json for strict JWT
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
    "Secret": "", 
    "Issuer": "ConstructionManagementApi_Production",
    "Audience": "ConstructionManagementClients_Secure",
    "ExpiryMinutes": 120
  },
  "FileStorage": {
    "BasePath": "Uploads"
  }
}
JSON
# Note: "Secret" is intentionally left blank here. In a real production environment, 
# this MUST be provided via Environment Variables (e.g. JwtSettings__Secret) or Azure Key Vault.

# 2. Update SecurityService to enforce secure secret retrieval
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
        private readonly string _issuer;
        private readonly string _audience;
        private readonly int _expiryMinutes;

        public SecurityService(IConfiguration configuration)
        {
            _secret = configuration["JwtSettings:Secret"];
            if (string.IsNullOrWhiteSpace(_secret) || _secret.Length < 32)
            {
                throw new InvalidOperationException("CRITICAL: JWT Secret is not configured securely. It must be provided via environment variables and be at least 32 characters long.");
            }
            
            _issuer = configuration["JwtSettings:Issuer"];
            _audience = configuration["JwtSettings:Audience"];
            _expiryMinutes = int.Parse(configuration["JwtSettings:ExpiryMinutes"] ?? "120");
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
                Expires = DateTime.UtcNow.AddMinutes(_expiryMinutes),
                Issuer = _issuer,
                Audience = _audience,
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = handler.CreateToken(descriptor);
            return handler.WriteToken(token);
        }
    }
}
CS

# 3. Update Program.cs to enforce strict JWT Validation (Https, Issuer, Audience)
cat << 'CS' > src/Api/ConstructionManagement.Api/Program.cs
using System.Text;
using System;
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

// Inject Application Services (To be created)
// builder.Services.AddScoped<IProjectService, ProjectService>();

var secret = builder.Configuration["JwtSettings:Secret"];
if (string.IsNullOrWhiteSpace(secret) || secret.Length < 32)
{
    // Fail fast on startup if security is compromised
    throw new InvalidOperationException("CRITICAL: JWT Secret must be provided in configuration (environment variables) and be at least 32 characters long.");
}

var key = Encoding.ASCII.GetBytes(secret);

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = true; // PRODUCTION SECURE: Enforce HTTPS
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true, // PRODUCTION SECURE
        ValidIssuer = builder.Configuration["JwtSettings:Issuer"],
        ValidateAudience = true, // PRODUCTION SECURE
        ValidAudience = builder.Configuration["JwtSettings:Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
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

app.Run();
CS

