using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;

namespace ConstructionManagement.Infrastructure.Services
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
