using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Security;

namespace ConstructionManagement.Application.Services
{
    public class FinanceService : IFinanceService
    {
        private readonly ApplicationDbContext _context;

        public FinanceService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<ProfitCalculationDto> CalculateProjectProfitAsync(Guid projectId, Guid? customerId, byte userType, bool includeOverhead)
        {
            if (userType == 2) throw new UnauthorizedAccessException("Customers cannot view profit calculations.");

            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (project == null) throw new KeyNotFoundException();

            decimal expenses = await _context.Expenses.Where(e => e.ProjectId == projectId).SumAsync(e => e.Amount);
            decimal contractorPayments = await _context.ContractorPayments.Where(c => c.ProjectId == projectId).SumAsync(c => c.Amount);
            
            decimal overhead = 0;
            if (includeOverhead)
            {
                // Simple logic: Company overhead / Total Projects
                var totalOverhead = await _context.Expenses.Where(e => e.ProjectId == null && e.CompanyId == project.CompanyId).SumAsync(e => e.Amount);
                var activeProjectsCount = await _context.Projects.CountAsync(p => p.CompanyId == project.CompanyId && p.Status != 5);
                if (activeProjectsCount > 0) overhead = totalOverhead / activeProjectsCount;
            }

            return new ProfitCalculationDto
            {
                ProjectId = projectId,
                CurrentContractValue = project.CurrentContractValue,
                TotalProjectExpenses = expenses,
                TotalContractorPayments = contractorPayments,
                AllocatedCompanyOverhead = includeOverhead ? overhead : null
            };
        }

        public async Task<CustomerPaymentDto> RecordCustomerPaymentAsync(CustomerPaymentDto dto, Guid userId)
        {
            var payment = new CustomerPayment
            {
                PaymentId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                Amount = dto.Amount,
                PaymentDate = dto.PaymentDate,
                PaymentMethod = dto.PaymentMethod,
                PaymentNumber = dto.PaymentNumber,
                Status = 2, // Confirmed
                CreatedBy = userId,
                CreatedAtUtc = DateTime.UtcNow
            };
            
            _context.CustomerPayments.Add(payment);
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), Action = "Payment", EntityName = "CustomerPayment", EntityId = payment.PaymentId.ToString(), TimestampUtc = DateTime.UtcNow, UserId = userId });
            
            await _context.SaveChangesAsync();
            dto.PaymentId = payment.PaymentId;
            return dto;
        }
    }
}
