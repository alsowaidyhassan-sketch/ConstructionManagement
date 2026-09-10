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
builder.Services.AddScoped<IContractService, ConstructionManagement.Application.Services.ContractService>();
builder.Services.AddScoped<IChangeOrderService, ConstructionManagement.Application.Services.ChangeOrderService>();
builder.Services.AddScoped<IFinanceService, ConstructionManagement.Application.Services.FinanceService>();
builder.Services.AddScoped<IDocumentService, ConstructionManagement.Application.Services.DocumentService>();
builder.Services.AddScoped<IReportService, ConstructionManagement.Application.Services.ReportService>();

// Inject Application Services (To be created)
builder.Services.AddScoped<IProjectService, ConstructionManagement.Application.Services.ProjectService>();

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
