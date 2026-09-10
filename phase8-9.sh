#!/bin/bash
# DTOs
cat << 'CS' > src/Application/DTOs/ReportDtos.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ReportDto
    {
        public string Title { get; set; }
        public DateTime GeneratedAt { get; set; }
        public object Data { get; set; }
    }
}
CS

# Services
cat << 'CS' > src/Application/Interfaces/IReportService.cs
using System;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IReportService
    {
        Task<ReportDto> GetProjectStatementAsync(Guid projectId, Guid? customerId, byte userType);
    }
}
CS

cat << 'CS' > src/Application/Services/ReportService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;

namespace ConstructionManagement.Application.Services
{
    public class ReportService : IReportService
    {
        private readonly ApplicationDbContext _context;

        public ReportService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<ReportDto> GetProjectStatementAsync(Guid projectId, Guid? customerId, byte userType)
        {
            var project = await _context.Projects.Include(p => p.Customer).FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (project == null) throw new KeyNotFoundException();
            
            if (userType == 2 && project.CustomerId != customerId) throw new UnauthorizedAccessException();

            var payments = await _context.CustomerPayments.Where(p => p.ProjectId == projectId).ToListAsync();

            var data = new
            {
                ProjectName = project.ProjectName,
                CustomerName = project.Customer?.FullNameAr,
                ContractValue = project.CurrentContractValue,
                TotalPaid = payments.Sum(p => p.Amount),
                Remaining = project.CurrentContractValue - payments.Sum(p => p.Amount),
                Payments = payments.Select(p => new { p.PaymentNumber, p.Amount, p.PaymentDate })
            };

            return new ReportDto
            {
                Title = "كشف حساب مشروع",
                GeneratedAt = DateTime.UtcNow,
                Data = data
            };
        }
    }
}
CS

# DI Registration update
cat << 'CS' > update_di.cs
using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        var path = "src/Api/ConstructionManagement.Api/Program.cs";
        var content = File.ReadAllText(path);
        
        var servicesToAdd = @"
builder.Services.AddScoped<IContractService, ConstructionManagement.Application.Services.ContractService>();
builder.Services.AddScoped<IChangeOrderService, ConstructionManagement.Application.Services.ChangeOrderService>();
builder.Services.AddScoped<IFinanceService, ConstructionManagement.Application.Services.FinanceService>();
builder.Services.AddScoped<IDocumentService, ConstructionManagement.Application.Services.DocumentService>();
builder.Services.AddScoped<IReportService, ConstructionManagement.Application.Services.ReportService>();
";
        
        if (!content.Contains("IContractService"))
        {
            content = content.Replace("builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();", 
                "builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();\n" + servicesToAdd);
            File.WriteAllText(path, content);
        }
    }
}
CS
mcs update_di.cs && mono update_di.exe || echo "mcs not found, manually modifying..."
# Fallback sed if mono not available
sed -i '/builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();/a \
builder.Services.AddScoped<IContractService, ConstructionManagement.Application.Services.ContractService>();\
builder.Services.AddScoped<IChangeOrderService, ConstructionManagement.Application.Services.ChangeOrderService>();\
builder.Services.AddScoped<IFinanceService, ConstructionManagement.Application.Services.FinanceService>();\
builder.Services.AddScoped<IDocumentService, ConstructionManagement.Application.Services.DocumentService>();\
builder.Services.AddScoped<IReportService, ConstructionManagement.Application.Services.ReportService>();' src/Api/ConstructionManagement.Api/Program.cs

